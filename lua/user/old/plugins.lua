-- Install packer
-- local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
-- local is_bootstrap = false
-- if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
--     is_bootstrap = true
--     vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
--     vim.cmd [[packadd packer.nvim]]
-- end

local packer = require("packer")

-- Plugins
return packer.startup(function(use)
    use("wbthomason/packer.nvim")
    use({"folke/tokyonight.nvim"})

    -- lsp
    use({"neovim/nvim-lspconfig" -- config = function()
    --     require("user.lsp")
    -- end
    })
    use({"williamboman/mason.nvim"})
    use({"williamboman/mason-lspconfig.nvim"})

    -- Snippets
    use("rafamadriz/friendly-snippets")
    use({"windwp/nvim-autopairs"})

    -- cmp
    use("hrsh7th/cmp-nvim-lsp")
    use("hrsh7th/cmp-buffer")
    use("hrsh7th/cmp-path")
    use("hrsh7th/cmp-cmdline")
    use("hrsh7th/cmp-nvim-lsp-signature-help")
    use({
        "L3MON4D3/LuaSnip",
        after = "nvim-cmp"
        -- config = function()
        --     require("user.luasnip")
        -- end
    })
    use({"hrsh7th/nvim-cmp" -- config = function()
    --     require("user.cmp")
    -- end
    })
    use("saadparwaiz1/cmp_luasnip")

    -- null-ls
    use({"jose-elias-alvarez/null-ls.nvim"})
    use({"jayp0521/mason-null-ls.nvim"})

    use({
        "nvim-lualine/lualine.nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    })
    use({
        "akinsho/bufferline.nvim",
        tag = "v2.*",
        requires = "kyazdani42/nvim-web-devicons"
    })
    use({
        "nvim-treesitter/nvim-treesitter",
        run = function()
            local ts_update = require('nvim-treesitter.install').update({
                with_sync = true
            })
            ts_update()
        end
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
    use {
        'nvim-telescope/telescope-fzf-native.nvim',
        run = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
    }

    -- Misc
    use({
        "goolord/alpha-nvim",
        requires = {"kyazdani42/nvim-web-devicons"}
    })

    -- Git
    use({
        "TimUntersberger/neogit",
        requires = "nvim-lua/plenary.nvim",
        ccommit = "71651625b0cccb95bd1ae152d26bcf26d96e5182"
    })
    -- use({
    --     "kyazdani42/nvim-tree.lua",
    --     requires = {"kyazdani42/nvim-web-devicons"},
    --     tag = "nightly"
    -- })

    use({"ggandor/leap.nvim"})

    use({"rcarriga/nvim-notify"})

    use({"lukas-reineke/indent-blankline.nvim"})

    use({
        "kylechui/nvim-surround",
        tag = "*"
    })

    -- use {
    --     'lewis6991/gitsigns.nvim',
    --     requires = {'nvim-lua/plenary.nvim'}
    -- }

    -- if is_bootstrap then
    --     require('packer').sync()
    --     print '=================================='
    --     print '    Plugins are being installed'
    --     print '    Wait until Packer completes,'
    --     print '       then restart nvim'
    --     print '=================================='
    -- end
end)

-- You'll need to restart nvim, and then it will work.
-- if is_bootstrap then
--     print '=================================='
--     print '    Plugins are being installed'
--     print '    Wait until Packer completes,'
--     print '       then restart nvim'
--     print '=================================='
--     return
-- end

-- Automatically source and re-compile packer whenever you save this init.lua
-- local packer_group = vim.api.nvim_create_augroup('Packer', {
--     clear = true
-- })
-- vim.api.nvim_create_autocmd('BufWritePost', {
--     command = 'source <afile> | PackerCompile',
--     group = packer_group,
--     pattern = vim.fn.expand '$MYVIMRC'
-- })
