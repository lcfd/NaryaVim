-- Django Cotton Neovim plugin
-- Provides go-to-definition and autocompletion for Django Cotton templates

local M = {}

-- Plugin configuration
M.config = {
  template_paths = { "templates/cotton" },
  filetypes = { "html", "htmldjango", "django" },
}

-- Internal state
local cotton_components = {}
local ns_id = vim.api.nvim_create_namespace("django_cotton")

-- Utility functions
local function get_project_root()
  local root_patterns = { "manage.py", ".git", "pyproject.toml", "requirements.txt" }
  return vim.fs.dirname(vim.fs.find(root_patterns, { upward = true })[1])
end

local function scan_cotton_templates()
  local root = get_project_root()
  if not root then
    return
  end

  cotton_components = {}

  for _, template_path in ipairs(M.config.template_paths) do
    local full_path = root .. "/" .. template_path
    if vim.fn.isdirectory(full_path) == 1 then
      local files = vim.fn.glob(full_path .. "/**/*.html", false, true)

      for _, file in ipairs(files) do
        local relative_path = file:gsub(full_path .. "/", "")
        local component_name = relative_path:gsub("%.html$", ""):gsub("/", ".")

        -- Read template file to extract documentation
        local doc = ""
        local content = vim.fn.readfile(file)
        for _, line in ipairs(content) do
          local comment = line:match("<!%-%-(.-)%-%->")
          if comment then
            doc = doc .. comment:gsub("^%s*", ""):gsub("%s*$", "") .. "\n"
          end
        end

        cotton_components[component_name] = {
          file = file,
          doc = doc:gsub("\n$", ""),
        }
      end
    end
  end
end

-- LSP-compatible go to definition
local function get_cotton_definition()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  local col = cursor[2]

  -- Find cotton tag at cursor position
  local start_pos, end_pos
  for i = col, 1, -1 do
    if line:sub(i, i + 1) == "<c" then
      start_pos = i
      break
    end
  end

  if not start_pos then
    return nil
  end

  for i = col, #line do
    if line:sub(i, i) == ">" then
      end_pos = i
      break
    end
  end

  if not end_pos then
    return nil
  end

  local tag = line:sub(start_pos, end_pos)
  local component_name = tag:match("<c%-([%w%.%-_]+)")

  if component_name and cotton_components[component_name] then
    return {
      uri = vim.uri_from_fname(cotton_components[component_name].file),
      range = {
        start = { line = 0, character = 0 },
        ["end"] = { line = 0, character = 0 },
      },
    }
  end

  return nil
end

-- Mock LSP handler for Cotton definitions
local function cotton_definition_handler(_, result, ctx, config)
  if result then
    vim.lsp.util.jump_to_location(result, "utf-8")
  end
end

-- Blink.cmp source
local blink_source = {}

function blink_source.new()
  return setmetatable({}, { __index = blink_source })
end

function blink_source:get_completions(ctx, callback)
  local line = vim.api.nvim_get_current_line()
  local col = ctx.cursor.col

  -- Check if we're in a cotton tag context
  local before_cursor = line:sub(1, col - 1)
  if not before_cursor:match("<c%-?[%w%.%-_]*$") then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end

  local prefix = before_cursor:match("<c%-?([%w%.%-_]*)$") or ""
  local items = {}

  for component_name, component_data in pairs(cotton_components) do
    if component_name:find("^" .. vim.pesc(prefix), 1, true) then
      table.insert(items, {
        label = "c-" .. component_name,
        kind = require("blink.cmp").lsp_kind_names.Snippet,
        detail = "Cotton Component",
        documentation = component_data.doc ~= "" and component_data.doc or nil,
        insertText = "-" .. component_name .. ">$0</" .. "c-" .. component_name .. ">",
        insertTextFormat = 2, -- Snippet format
      })
    end
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items,
  })
end

function blink_source:resolve(item, callback)
  callback(item)
end

function blink_source:execute(item, callback)
  callback()
end

-- Setup LSP integration for Telescope
local function setup_lsp_integration()
  -- Override textDocument/definition handler for Cotton files
  local original_handler = vim.lsp.handlers["textDocument/definition"]

  vim.lsp.handlers["textDocument/definition"] = function(err, result, ctx, config)
    -- Check if we're in a Cotton context
    local cotton_def = get_cotton_definition()
    if cotton_def then
      cotton_definition_handler(err, cotton_def, ctx, config)
      return
    end

    -- Fall back to original handler
    if original_handler then
      original_handler(err, result, ctx, config)
    end
  end
end

-- Highlight cotton tags
local function highlight_cotton_tags()
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    for match in line:gmatch("<c%-[%w%.%-_]+[^>]*>") do
      local start_col = line:find(match, 1, true) - 1
      local end_col = start_col + #match

      vim.api.nvim_buf_add_highlight(0, ns_id, "CottonTag", i - 1, start_col, end_col)
    end
  end
end

-- Setup function
function M.setup(opts)
  opts = opts or {}
  M.config = vim.tbl_deep_extend("force", M.config, opts)

  -- Define highlight groups
  vim.api.nvim_set_hl(0, "CottonTag", { fg = "#61afef", bold = true })

  -- Scan templates on startup
  vim.schedule(scan_cotton_templates)

  -- Setup autocommands
  local group = vim.api.nvim_create_augroup("DjangoCotton", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = M.config.filetypes,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()

      -- Set up highlighting
      vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
        group = group,
        buffer = buf,
        callback = highlight_cotton_tags,
      })

      -- Initial highlighting
      highlight_cotton_tags()
    end,
  })

  -- Rescan templates when files change
  vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    group = group,
    pattern = "*.html",
    callback = function()
      local file = vim.fn.expand("%:p")
      for _, template_path in ipairs(M.config.template_paths) do
        if file:find(template_path, 1, true) then
          scan_cotton_templates()
          break
        end
      end
    end,
  })

  -- Setup blink.cmp integration
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    blink.setup({
      sources = {
        providers = {
          cotton = {
            name = "Django Cotton",
            module = "django-cotton.blink",
          },
        },
      },
    })
  end

  setup_lsp_integration()
end

-- Commands
vim.api.nvim_create_user_command("CottonRescan", function()
  scan_cotton_templates()
  vim.notify("Cotton templates rescanned")
end, { desc = "Rescan Cotton templates" })

vim.api.nvim_create_user_command("CottonList", function()
  local items = {}
  for name, data in pairs(cotton_components) do
    table.insert(items, {
      text = name,
      filename = data.file,
      lnum = 1,
      col = 1,
    })
  end

  vim.fn.setqflist(items)
  vim.cmd("copen")
end, { desc = "List all Cotton components" })

-- Expose blink source
M.blink_source = blink_source

-- Expose completion function globally (kept for backward compatibility)
M.complete = function() end

return M
