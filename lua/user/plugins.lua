local packer = require("packer")

local status_ok, impatient = pcall(require, "impatient")
if not status_ok then
    vim.notify("Problem with impatient")
    return
end

-- Plugins
return packer.startup(function(use)
    use("wbthomason/packer.nvim")
    use("lewis6991/impatient.nvim")
    use("folke/tokyonight.nvim")

    -- lsp
    use({
        "neovim/nvim-lspconfig",
        config = function()
            require("user.lsp.lspconfig")
        end
    })
    use({
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup({})
        end
    })
    use({
        "williamboman/mason-lspconfig.nvim",
        config = function()
            require("user.lsp.masonlspconfig")
        end
    })

    -- Snippets
    use("rafamadriz/friendly-snippets")
    use({
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup()
        end
    })

    -- cmp
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use({
        "L3MON4D3/LuaSnip",
        after = "nvim-cmp",
        config = function()
            require("user.luasnip")
        end
    })
    use({
        "hrsh7th/nvim-cmp",
        config = function()
            require("user.cmp")
        end
    })
    use("saadparwaiz1/cmp_luasnip")

    -- null-ls
    use("jose-elias-alvarez/null-ls.nvim")
    use("jayp0521/mason-null-ls.nvim")

    use({
        "nvim-lualine/lualine.nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    })
    use("famiu/bufdelete.nvim")
    use({
        "akinsho/bufferline.nvim",
        tag = "v2.*",
        requires = "kyazdani42/nvim-web-devicons"
    })
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate"
    })
    use("numToStr/Comment.nvim")

    -- Telescope
    use({
        "nvim-telescope/telescope.nvim",
        tag = "0.1.x",
        requires = {{"nvim-lua/plenary.nvim"}}
    })
    use("nvim-telescope/telescope-file-browser.nvim")
    use("nvim-telescope/telescope-symbols.nvim")
    use("nvim-telescope/telescope-project.nvim")

    -- Misc
    use({
        "goolord/alpha-nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    })

    -- Git
    use({
        "TimUntersberger/neogit",
        requires = "nvim-lua/plenary.nvim"
    }) -- https://github.com/TimUntersberger/neogit

    use({
        "kyazdani42/nvim-tree.lua",
        requires = {"kyazdani42/nvim-web-devicons"},
        tag = "nightly"
    })
end)
