local M = {}

function M.setup()
  local dapui_ok, dapui = pcall(require, "dapui")
  if not dapui_ok then
    vim.notify("Problems with dapui")
    return
  end

  local nvim_dap_virtual_text_ok, nvim_dap_virtual_text = pcall(require, "nvim-dap-virtual-text")
  if not nvim_dap_virtual_text_ok then
    vim.notify("Problems with nvim-dap-virtual-text")
    return
  end

  dapui.setup()
  nvim_dap_virtual_text.setup()
end

return M
