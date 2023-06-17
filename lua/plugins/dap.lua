return {
  {
    "mfussenegger/nvim-dap",
  },
  {
    "mfussenegger/nvim-dap-python",
    build = "~/.config/nvim/venv/bin/pip install debugpy",
  },
  {
    "mxsdev/nvim-dap-vscode-js",
  },
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
  },
  {
    "rcarriga/nvim-dap-ui",
  },
  {
    "theHamsta/nvim-dap-virtual-text",
  },
  {
    "nvim-telescope/telescope-dap.nvim",
  },
}
