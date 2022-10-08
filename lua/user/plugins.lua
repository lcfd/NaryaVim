-- Plugins
return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "folke/tokyonight.nvim"
    use 'honza/vim-snippets' -- Fill coc-snippets
    use {
        "neoclide/coc.nvim",
        branch = "release"
    }
    use {
        "nvim-lualine/lualine.nvim",
        requires = {
            "kyazdani42/nvim-web-devicons",
            opt = true
        }
    }
    use {
        'kyazdani42/nvim-tree.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        tag = 'nightly'
    }
    use "famiu/bufdelete.nvim"
    use {
        'akinsho/bufferline.nvim',
        tag = "v2.*",
        requires = 'kyazdani42/nvim-web-devicons'
    }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    use {'numToStr/Comment.nvim'}
    use {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.x',
        requires = {{'nvim-lua/plenary.nvim'}}
    }

    -- Git

    use {
        'TimUntersberger/neogit',
        requires = 'nvim-lua/plenary.nvim'
    } -- https://github.com/TimUntersberger/neogit

    -- Maybe
    use("nathom/filetype.nvim") -- https://github.com/nathom/filetype.nvim
    use("ellisonleao/glow.nvim") -- https://github.com/ellisonleao/glow.nvim
    use("ja-ford/delaytrain.nvim")
end)
