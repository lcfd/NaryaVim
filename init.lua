local merge = require("narya.utils.merge")
local config = require("narya.default_config")
local has_user_config, user_config = pcall(require, "user.config")

if has_user_config then
    config = merge(config, user_config)
end

require("narya.options").setup()

local plugins = require "narya.plugins"
plugins.load(plugins.list)

require("narya.misc").setup(config)

require("narya.telescope").setup()
require("narya.lualine").setup()

require("narya.alpha").setup(config)

require("narya.commands").setup()

require("narya.null-ls").setup()

require("narya.cmp").setup()

require("narya.keymaps").setup(config)

require("narya.lsp").setup()
require("narya.treesitter").setup()

require("narya.quicklinks").setup(config)
