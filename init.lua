local merge = require("narya.utils.merge")
local config = require("narya.default_config")
local has_user_config, user_config = pcall(require, "user.config")

if has_user_config then
  config = merge(config, user_config)
end

require("narya.options").setup()

require("narya.lazy").setup(config)

-- require("narya.misc").setup(config)

-- require("narya.commands").setup(config)

-- require("narya.null-ls").setup(config)

-- require("narya.cmp").setup(config)

require("narya.keymaps").setup(config)

-- require("narya.lsp").setup(config)
-- require("narya.treesitter").setup(config)
-- require("narya.dap").setup(config)
-- require("narya.tests").setup(config)
