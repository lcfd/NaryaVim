return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
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
        -- This plugin adds virtual text support to nvim-dap. nvim-treesitter is used to find variable definitions.
        "theHamsta/nvim-dap-virtual-text",
      },
    },
    config = function(_, opts)
      local dap_ok, dap = pcall(require, "dap")
      if not dap_ok then
        vim.notify("Problems with dap")
        return
      end

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

      -- Dap specific languages support

      -- Python
      require("dap-python").setup("~/.config/nvim/venv/bin/python")

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Django",
        program = vim.fn.getcwd() .. "/manage.py",
        args = { "runserver", "--noreload" },
      })

      -- JavaScript

      require("dap-vscode-js").setup({
        -- node_path = "node", -- Path of node executable. Defaults to $NODE_PATH, and then "node"
        -- debugger_path = "(runtimedir)/site/pack/packer/opt/vscode-js-debug", -- Path to vscode-js-debug installation.
        -- debugger_cmd = { "js-debug-adapter" }, -- Command to use to launch the debug server. Takes precedence over `node_path` and `debugger_path`.
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
        -- log_file_path = "(stdpath cache)/dap_vscode_js.log" -- Path for file logging
        -- log_file_level = false -- Logging level for output to file. Set to false to disable file logging.
        -- log_console_level = vim.log.levels.ERROR -- Logging level for output to console. Set to false to disable console output.
      })

      for _, language in ipairs({ "typescript", "javascript" }) do
        require("dap").configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch file",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end

      -- Automagically open dapui when start debugging

      dap.listeners.after.event_initialized["dapui.config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui.config"] = function()
        dapui.close()
      end

      dap.listeners.after.event_exited["dapui.config"] = function()
        dapui.close()
      end
    end,
  },
  {
    "nvim-telescope/telescope-dap.nvim",
  },
}
