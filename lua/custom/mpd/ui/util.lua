-- Window, buffer and image helpers shared by the UI.
local M = {}

--- Writes lines given as lists of { text, hl_group? } chunks.
function M.set_chunks(buf, ns, rows)
  local lines, marks = {}, {}
  for r, chunks in ipairs(rows) do
    local line = ""
    for _, chunk in ipairs(chunks) do
      if chunk[2] then
        table.insert(marks, { r - 1, #line, #line + #chunk[1], chunk[2] })
      end
      line = line .. chunk[1]
    end
    lines[r] = line
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
end

--- Opens a float (without entering it) styled like the Snacks picker.
function M.float_win(buf, cfg)
  local win = vim.api.nvim_open_win(buf, false, cfg)
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight =
    "Normal:SnacksPicker,NormalFloat:SnacksPicker,FloatBorder:SnacksPickerBorder,FloatTitle:SnacksPickerTitle"
  return win
end

function M.scratch()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  return buf
end

--- Snacks recognises Ghostty only from its reply to an XTVERSION query. When
--- that reply is missed, "unsupported" is cached for the whole session, so
--- fall back to the environment Ghostty sets.
function M.images_supported()
  if Snacks.image.supports_terminal() then
    return true
  end
  local ghostty = vim.env.GHOSTTY_RESOURCES_DIR
    or vim.env.TERM_PROGRAM == "ghostty"
    or (vim.env.TERM or ""):find("ghostty")
  if ghostty and not vim.env.SNACKS_GHOSTTY then
    vim.env.SNACKS_GHOSTTY = "1"
    Snacks.image.terminal._env = nil -- recompute with the override
  end
  return Snacks.image.supports_terminal()
end

return M
