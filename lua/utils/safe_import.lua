return function(pkg)
  local s, p = pcall(require, pkg)
  if not s then
    local message = string.format("Setup: [%s] package", myVar)
    vim.notify(message, "error")
    return
  end

  return p
end
