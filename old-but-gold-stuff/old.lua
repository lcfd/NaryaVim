return {
    {
        "kkoomen/vim-doge",
        build = ":call doge#install()",
        lazy = true
    },
    {
        "nanotee/zoxide.vim"
    },
    {
        "catppuccin/nvim",
        lazy = false,
        priority = 1000,
        name = "catppuccin",
        opts = {
            flavour = "macchiato",
            integrations = {
                alpha = true,
                cmp = true,
                gitsigns = true,
                illuminate = true,
                indent_blankline = {
                    enabled = true
                },
                lsp_trouble = true,
                mini = true,
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = {
                            "undercurl"
                        },
                        hints = {
                            "undercurl"
                        },
                        warnings = {
                            "undercurl"
                        },
                        information = {
                            "undercurl"
                        }
                    }
                },
                navic = {
                    enabled = true
                },
                neotest = true,
                notify = true,
                nvimtree = true,
                semantic_tokens = true,
                telescope = true,
                treesitter = true,
                which_key = true
            }
        },
        config = function(_, opts)
            require("catppuccin").setup(opts)
            vim.cmd.colorscheme("catppuccin")
        end
    },
    {
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        config = true
    },
    {
        "folke/neodev.nvim",
        opts = {}
    }
}
