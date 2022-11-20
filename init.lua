require("narya.options").setup()

local plugins = require "narya.plugins"
plugins.load(plugins.list)

require("narya.misc").setup()

require("narya.telescope").setup()
require("narya.lualine").setup()
require("narya.alpha").setup()
require("narya.commands").setup()

require("narya.null-ls").setup()

require("narya.cmp").setup()

require("narya.keymaps").setup()

require("narya.lsp").setup()
require("narya.treesitter").setup()
