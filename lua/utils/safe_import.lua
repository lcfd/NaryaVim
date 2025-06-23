return function(pkg)
  local s, p = pcall(require, pkg)
  if not s then
    local message = string.format("Setup: [%s] package", p)
    vim.notify(message, "error")
    return nil
  end

  return p
end
