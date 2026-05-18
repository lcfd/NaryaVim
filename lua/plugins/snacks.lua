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
    scope = {
      enabled = true,
      treesitter = {
        enabled = true,
        injections = true,
        blocks = {
          enabled = true, -- Auto-extracts loops, conditionals, methods, functions, and classes
          "function_declaration",
          "function_definition",
          "method_declaration",
          "method_definition",
          "if_statement",
          "for_statement",
          "while_statement",
          "class_declaration",
        },
      },
    },
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

    -- ==========================================
    -- 1. SELECT (Text Objects)
    -- ==========================================
    {
      "ii",
      function()
        Snacks.scope.textobject({ edge = false })
      end,
      mode = { "o", "x" },
      desc = "inner conditional/scope block",
    },
    {
      "ai",
      function()
        Snacks.scope.textobject({ edge = true })
      end,
      mode = { "o", "x" },
      desc = "outer conditional/scope block",
    },

    {
      "il",
      function()
        Snacks.scope.textobject({ edge = false })
      end,
      mode = { "o", "x" },
      desc = "inner loop structural block",
    },
    {
      "al",
      function()
        Snacks.scope.textobject({ edge = true })
      end,
      mode = { "o", "x" },
      desc = "outer loop structural block",
    },

    {
      "if",
      function()
        Snacks.scope.textobject({ edge = false })
      end,
      mode = { "o", "x" },
      desc = "inner method/function def",
    },
    {
      "af",
      function()
        Snacks.scope.textobject({ edge = true })
      end,
      mode = { "o", "x" },
      desc = "outer method/function def",
    },

    {
      "ic",
      function()
        Snacks.scope.textobject({ edge = false })
      end,
      mode = { "o", "x" },
      desc = "inner class structure",
    },
    {
      "ac",
      function()
        Snacks.scope.textobject({ edge = true })
      end,
      mode = { "o", "x" },
      desc = "outer class structure",
    },

    -- Parameters and calls handled via native expression mapping
    {
      "ia",
      "v:lua.vim.treesitter.textobjects.select('@parameter.inner')",
      expr = true,
      mode = { "o", "x" },
      desc = "inner parameter/argument",
    },
    {
      "aa",
      "v:lua.vim.treesitter.textobjects.select('@parameter.outer')",
      expr = true,
      mode = { "o", "x" },
      desc = "outer parameter/argument",
    },
    {
      "im",
      "v:lua.vim.treesitter.textobjects.select('@call.inner')",
      expr = true,
      mode = { "o", "x" },
      desc = "inner function call",
    },
    {
      "am",
      "v:lua.vim.treesitter.textobjects.select('@call.outer')",
      expr = true,
      mode = { "o", "x" },
      desc = "outer function call",
    },

    -- ==========================================
    -- 2. MOVE (Stable Navigation Fix)
    -- ==========================================
    -- Method/Function jumps using Snacks.words
    {
      "]m",
      function()
        Snacks.words.jump(1)
      end,
      mode = { "n", "t" },
      desc = "Next method/function def start",
    },
    {
      "[m",
      function()
        Snacks.words.jump(-1)
      end,
      mode = { "n", "t" },
      desc = "Prev method/function def start",
    },
    {
      "]M",
      function()
        Snacks.words.jump(1)
        vim.cmd("normal! $")
      end,
      mode = { "n" },
      desc = "Next method/function def end",
    },
    {
      "[M",
      function()
        Snacks.words.jump(-1)
        vim.cmd("normal! $")
      end,
      mode = { "n" },
      desc = "Prev method/function def end",
    },

    -- Generic context scope jump mappings
    {
      "]s",
      function()
        Snacks.scope.jump({ bottom = true })
      end,
      mode = { "n" },
      desc = "Next scope block",
    },
    {
      "[s",
      function()
        Snacks.scope.jump({ bottom = false })
      end,
      mode = { "n" },
      desc = "Prev scope block",
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
