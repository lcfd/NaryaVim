return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    indent = {
      enabled = true,
      indent = {
        -- blank = "∙",
      },
      scope = {
        animate = {
          enabled = false,
        }
      },
      blank = {
        char = "·",
      }
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
Y                  Y    Y             Y             Y]]
      },
      sections = {
        { section = "header" },
        { section = "keys",   gap = 1, padding = 1 },
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
    }
  },
  keys = {
    { "<leader>gg", function() Snacks.lazygit() end,          desc = "Lazygit" },
    { "xx",         function() Snacks.bufdelete() end,        desc = "Delete Buffer" },
    { "xa",         function() Snacks.bufdelete.other() end,  desc = "Delete Buffer" },
    { "<leader>gb", function() Snacks.git.blame_line() end,   desc = "Git Blame Line" },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>z",  function() Snacks.zen() end,              desc = "Toggle Zen Mode" },
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
