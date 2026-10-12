-- The open modal (Command Center or Playlists), if any. Only one is open at a
-- time, and pickers opened from one leave it and bring it back when done.
local M = {}

---@class mpd.Modal
---@field picker snacks.Picker
---@field reopen fun() opens the modal again, as it was left

local active ---@type mpd.Modal?

local function is_open()
  return active ~= nil and not active.picker.closed
end

--- Registers a modal that just opened, closing the one that was open.
---@param modal mpd.Modal
function M.set(modal)
  if is_open() and active.picker ~= modal.picker then
    active.picker:close()
  end
  active = modal
end

--- Forgets the modal when it closes.
function M.clear(picker)
  if active and active.picker == picker then
    active = nil
  end
end

--- Closes the open modal, and returns a function that brings it back.
---@return fun()
function M.leave()
  if not is_open() then
    return function() end
  end
  local modal = active --[[@as mpd.Modal]]
  active = nil
  modal.picker:close()
  return modal.reopen
end

return M
