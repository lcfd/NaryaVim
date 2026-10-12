-- A focusable float filling an empty bordered box of a picker layout. Snacks
-- pickers only lay out their own windows (input, list, preview), so an extra
-- panel reserves its place with an empty box (`M.box`), found by its title.
local ui = require("custom.mpd.ui.util")

local M = {}

--- The layout box a panel titled `title` fills.
---@param size? { width?: number, height?: number }
function M.box(title, size)
  return vim.tbl_extend("force", { box = "vertical", border = true, title = title }, size or {})
end

local function cfg(picker, title)
  for _, box in pairs(picker.layout and picker.layout.box_wins or {}) do
    if box.meta and box.meta.title_tpl == title and box:valid() then
      local pos = vim.api.nvim_win_get_position(box.win) -- includes the border
      return {
        relative = "editor",
        row = pos[1] + 1,
        col = pos[2] + 1,
        width = vim.api.nvim_win_get_width(box.win),
        height = vim.api.nvim_win_get_height(box.win),
        zindex = (vim.api.nvim_win_get_config(box.win).zindex or 50) + 1,
      }
    end
  end
end

---@class mpd.PanelOpts
---@field title string title of the layout box to fill
---@field render fun(width: integer): table[] rows, as `set_chunks` chunks
---@field keys table<string, fun()> normal mode keymaps
---@field on_focus? fun(focused: boolean)
---@field on_cursor? fun(row: integer) the cursor moved, while focused

---@param opts mpd.PanelOpts
function M.new(opts)
  local panel = {}
  local ns = vim.api.nvim_create_namespace("custom.mpd.panel." .. opts.title)

  function panel.valid()
    return panel.win ~= nil and vim.api.nvim_win_is_valid(panel.win)
  end

  function panel.render()
    if panel.valid() then
      ui.set_chunks(panel.buf, ns, opts.render(vim.api.nvim_win_get_width(panel.win)))
    end
  end

  function panel.open(picker)
    local c = cfg(picker, opts.title)
    if not c then
      return
    end
    panel.buf = ui.scratch()
    panel.win = ui.float_win(panel.buf, vim.tbl_extend("force", c, { style = "minimal", noautocmd = true }))
    vim.wo[panel.win].winhighlight = vim.wo[panel.win].winhighlight .. ",CursorLine:SnacksPickerListCursorLine"
    panel.render()

    for lhs, fn in pairs(opts.keys) do
      vim.keymap.set("n", lhs, fn, { buffer = panel.buf, nowait = true })
    end

    -- the cursor line only marks the focused panel
    vim.api.nvim_create_autocmd({ "WinEnter", "WinLeave" }, {
      buffer = panel.buf,
      callback = function(ev)
        local focused = ev.event == "WinEnter"
        vim.wo[panel.win].cursorline = focused
        if opts.on_focus then
          opts.on_focus(focused)
        end
      end,
    })
    if opts.on_cursor then
      vim.api.nvim_create_autocmd("CursorMoved", {
        buffer = panel.buf,
        callback = function()
          opts.on_cursor(panel.cursor())
        end,
      })
    end
  end

  function panel.focused()
    return panel.valid() and vim.api.nvim_get_current_win() == panel.win
  end

  function panel.focus()
    if panel.valid() then
      vim.cmd.stopinsert()
      vim.api.nvim_set_current_win(panel.win)
    end
  end

  ---@return integer
  function panel.cursor()
    return panel.valid() and vim.api.nvim_win_get_cursor(panel.win)[1] or 1
  end

  function panel.set_cursor(row)
    if panel.valid() then
      row = math.max(1, math.min(row, vim.api.nvim_buf_line_count(panel.buf)))
      vim.api.nvim_win_set_cursor(panel.win, { row, 0 })
    end
  end

  --- Follows the picker after a resize.
  function panel.reposition(picker)
    local c = cfg(picker, opts.title)
    if c and panel.valid() then
      vim.api.nvim_win_set_config(panel.win, c)
      panel.render()
    end
  end

  function panel.close()
    if panel.valid() then
      vim.api.nvim_win_close(panel.win, true)
    end
    panel.win = nil
  end

  return panel
end

return M
