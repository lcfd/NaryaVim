return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    indent = {
      enabled = true,
      animate = {
        enabled = false,
      },
      indent = {
        -- blank = "∙",
      },
      scope = {
        animate = {
          enabled = false,
        },
      },
      blank = {
        char = "·",
      },
      picker = {},
    },
    animate = { enabled = true },
    lazygit = { enabled = true },
    bigfile = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scroll = { enabled = false },
    scope = { enabled = true },
    bufdelete = { enabled = true },
    git = { enabled = true },
    dim = { enabled = true },
    zen = { enabled = true },
    picker = {
      enabled = true,
      layout = {
        preset = "dropdown",
      },
    },
    --
    -- DASHBOARD
    --
    dashboard = {
      enabled = true,
      preset = {
        header = [[
.S_sSSs     .S_SSSs     .S_sSSs     .S S.    .S_SSSs
.SS~YS%%b   .SS~SSSSS   .SS~YS%%b   .SS SS.  .SS~SSSSS
S%S   `S%b  S%S   SSSS  S%S   `S%b  S%S S%S  S%S   SSSS
S%S    S%S  S%S    S%S  S%S    S%S  S%S S%S  S%S    S%S
S%S    S&S  S%S SSSS%S  S%S    d*S  S%S S%S  S%S SSSS%S
S&S    S&S  S&S  SSS%S  S&S   .S*S   SS SS   S&S  SSS%S
S&S    S&S  S&S    S&S  S&S_sdSSS     S S    S&S    S&S
S&S    S&S  S&S    S&S  S&S~YSY%b     SSS    S&S    S&S
S*S    S*S  S*S    S&S  S*S   `S%b    S*S    S*S    S&S
S*S    S*S  S*S    S*S  S*S    S%S    S*S    S*S    S*S
S*S    S*S  S*S    S*S  S*S    S&S    S*S    S*S    S*S
S*S    SSS  SSS    S*S  S*S    SSS    S*S    SSS    S*S
SP                 SP   SP            SP            SP
Y                  Y    Y             Y             Y]],
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        { section = "startup" },
        {
          pane = 2,
          icon = " ",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
        },
        function()
          local in_git = Snacks.git.get_root() ~= nil
          local cmds = {
            {
              title = "Open Issues",
              cmd = "gh issue list --assignee '@me' -L 10",
              key = "i",
              action = function()
                vim.fn.jobstart("gh issue list --assignee '@me' --web", { detach = true })
              end,
              icon = " ",
              height = 15,
            },
            {
              icon = " ",
              title = "Open PRs",
              cmd = "gh pr list --assignee='@me' -L 3",
              key = "p",
              action = function()
                vim.fn.jobstart("gh pr list --assignee='@me' --web", { detach = true })
              end,
              height = 9,
            },
            {
              icon = " ",
              title = "Git Status",
              cmd = "git status",
              height = 8,
            },
          }
          return vim.tbl_map(function(cmd)
            return vim.tbl_extend("force", {
              pane = 2,
              section = "terminal",
              enabled = in_git,
              padding = 1,
              ttl = 5 * 60,
              indent = 3,
            }, cmd)
          end, cmds)
        end,
      },
    },
  },
  keys = {
    {
      "<leader>fr",
      function()
        Snacks.picker.resume()
      end,
      desc = "Resume Last Picker",
    },
    {
      "<leader>gg",
      function()
        Snacks.lazygit()
      end,
      desc = "Lazygit",
    },
    {
      "xx",
      function()
        Snacks.bufdelete()
      end,
      desc = "Delete Buffer",
    },
    {
      "xa",
      function()
        Snacks.bufdelete.other()
      end,
      desc = "Delete Buffer",
    },
    {
      "<leader>gb",
      function()
        Snacks.git.blame_line()
      end,
      desc = "Git Blame Line",
    },
    {
      "<leader>gf",
      function()
        Snacks.lazygit.log_file()
      end,
      desc = "Lazygit Current File History",
    },
    {
      "<leader>z",
      function()
        Snacks.zen()
      end,
      desc = "Toggle Zen Mode",
    },
    -- Top Pickers & Explorer
    {
      "<leader><space>",
      function()
        Snacks.picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>p",
      function()
        Snacks.explorer()
      end,
      desc = "File Explorer",
    },
    -- Find
    {
      "<leader>fo",
      function()
        Snacks.picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>fi",
      function()
        Snacks.picker.lines({
          layout = {
            preset = "dropdown",
          },
        })
      end,
      desc = "Search in current buffer",
    },
    {
      "<leader>fw",
      function()
        Snacks.picker.grep()
      end,
      desc = "Find word in the project",
    },
    {
      "<leader>fW",
      function()
        Snacks.picker.grep_word()
      end,
      desc = "Visual selection or word",
      mode = { "n", "x" },
    },

    -- Todo
    {
      "<leader>gt",
      function()
        Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } })
      end,
      desc = "Todo/Fix/Fixme",
    },

    -- LSP
    {
      "gd",
      function()
        Snacks.picker.lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    {
      "gD",
      function()
        Snacks.picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "gr",
      function()
        Snacks.picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    {
      "gi",
      function()
        Snacks.picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
    },
    {
      "gy",
      function()
        Snacks.picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },
    {
      "gai",
      function()
        Snacks.picker.lsp_incoming_calls()
      end,
      desc = "C[a]lls Incoming",
    },
    {
      "gao",
      function()
        Snacks.picker.lsp_outgoing_calls()
      end,
      desc = "C[a]lls Outgoing",
    },
    {
      "<leader>ds",
      function()
        Snacks.picker.lsp_symbols({
          tree = true,
          filter = {
            default = {
              "Class",
              "Method",
              "Function",
              "Interface",
              "Struct",
              "Variable",
            },
          },
          -- layout = { preset = "vscode", preview = true },
          -- Custom transform to filter out the noise
          transform = function(item)
            -- 1. Get the symbol name
            local name = item.text

            -- 2. Filter out common React noise
            -- Excludes symbols starting with 'use' (hooks) or lowercase letters (common vars)
            -- But keeps Uppercase (Components) and '_' (often used for styled components/exports)
            if name:match("^use%A") or name:match("^[a-z]") then
              return false
            end

            -- 1. Hide actual anonymous labels
            if name:match("<anonymous>") then
              return false
            end

            -- 2. Hide common callback patterns (e.g., "() => ...")
            if name:match("=>") or name:match("^function%s*%(") then
              return false
            end

            return item
          end,
        })
      end,
      desc = "LSP Symbols",
    },
    {
      "<leader>dS",
      function()
        Snacks.picker.lsp_workspace_symbols()
      end,
      desc = "LSP Workspace Symbols",
    },
    --search
    {
      "<leader>lk",
      function()
        Snacks.picker.diagnostics_buffer()
      end,
      desc = "Buffer Diagnostics",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Create some toggle mappings
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
      end,
    })
  end,
}
