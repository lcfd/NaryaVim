-- Plugins
return require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "folke/tokyonight.nvim"
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
end)
