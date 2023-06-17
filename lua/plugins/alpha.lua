return {
  "goolord/alpha-nvim",
  event = "VimEnter",
  config = function()
    local status_ok, alpha = pcall(require, "alpha")
    if not status_ok then
      vim.notify("Require alpha", "error")
      return
    end

    local dashboard = require("alpha.themes.dashboard")

    -- Font name: AMC AAA01

    dashboard.section.header.val = {
      "                                                           ",
      "  .S_sSSs     .S_SSSs     .S_sSSs     .S S.    .S_SSSs     ",
      "  .SS~YS%%b   .SS~SSSSS   .SS~YS%%b   .SS SS.  .SS~SSSSS   ",
      "  S%S   `S%b  S%S   SSSS  S%S   `S%b  S%S S%S  S%S   SSSS  ",
      "  S%S    S%S  S%S    S%S  S%S    S%S  S%S S%S  S%S    S%S  ",
      "  S%S    S&S  S%S SSSS%S  S%S    d*S  S%S S%S  S%S SSSS%S  ",
      "  S&S    S&S  S&S  SSS%S  S&S   .S*S   SS SS   S&S  SSS%S  ",
      "  S&S    S&S  S&S    S&S  S&S_sdSSS     S S    S&S    S&S  ",
      "  S&S    S&S  S&S    S&S  S&S~YSY%b     SSS    S&S    S&S  ",
      "  S*S    S*S  S*S    S&S  S*S   `S%b    S*S    S*S    S&S  ",
      "  S*S    S*S  S*S    S*S  S*S    S%S    S*S    S*S    S*S  ",
      "  S*S    S*S  S*S    S*S  S*S    S&S    S*S    S*S    S*S  ",
      "  S*S    SSS  SSS    S*S  S*S    SSS    S*S    SSS    S*S  ",
      "  SP                 SP   SP            SP            SP   ",
      "  Y                  Y    Y             Y             Y    ",
      "                                                           ",
      "                         ~NEOVIM~                          ",
    }

    local button = dashboard.button

    dashboard.section.buttons.val = {
      button("e", "📄  New file", "<cmd>ene <CR>"),
      button("SPC SPC", "🔎  Find file"),
      button("SPC f w", "🈁  Find word"),
      button("SPC f o", "🗿  Old files"),
      button("SPC p p", "🗂  Projects"),
    }

    dashboard.section.buttons.opts.spacing = 1

    dashboard.section.footer.val = {
      "                                                             ",
      "                             🍜 🪷                             ",
      "                                                             ",
      "                   github.com/lcfd/NaryaVim                  ",
      "                                                             ",
    }

    alpha.setup(dashboard.opts)
  end,
}
