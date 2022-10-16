local packer = require "packer"

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

    -- cmp
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use("hrsh7th/nvim-cmp")
    use({
        "L3MON4D3/LuaSnip",
        tag = "v<CurrentMajor>.*"
    })

    -- Snippets
    use("saadparwaiz1/cmp_luasnip")
    use("rafamadriz/friendly-snippets")
    use("windwp/nvim-autopairs")

    -- lsp
    use("neovim/nvim-lspconfig")
    use("williamboman/mason.nvim")
    use("williamboman/mason-lspconfig.nvim")
    use("neovim/nvim-lspconfig")

    -- null-ls
    use("jose-elias-alvarez/null-ls.nvim")
    use("jayp0521/mason-null-ls.nvim")

    use {
        "nvim-lualine/lualine.nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    }
    use("famiu/bufdelete.nvim")
    use {
        'akinsho/bufferline.nvim',
        tag = "v2.*",
        requires = 'kyazdani42/nvim-web-devicons'
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use('numToStr/Comment.nvim')

    -- Telescope
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.x',
        requires = {{'nvim-lua/plenary.nvim'}}
    }
    use("nvim-telescope/telescope-file-browser.nvim")
    use('nvim-telescope/telescope-symbols.nvim')
    use('nvim-telescope/telescope-project.nvim')

    -- Misc
    use {
        'goolord/alpha-nvim',
        requires = {'kyazdani42/nvim-web-devicons'}
    }

    -- Git
    use {
        'TimUntersberger/neogit',
        requires = 'nvim-lua/plenary.nvim'
    } -- https://github.com/TimUntersberger/neogit

    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        tag = 'nightly'
    }

    -- Maybe
    use("nathom/filetype.nvim") -- https://github.com/nathom/filetype.nvim

    -- Tmp
    use("ja-ford/delaytrain.nvim")
end)
