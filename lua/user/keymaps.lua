local keyset = vim.keymap.set

local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
if not status_ok then
    return
end

-- ########################
-- ####### Generic ########
-- ########################

-- Set space as leader
vim.g.mapleader = " "
keyset("", "<Space>", "<Nop>")

-- Avoid press shift to type :
keyset("n", ";", ":")

-- ###############################
-- ####### telescope.nvim ########
-- ###############################

keyset('n', '<leader>ff', tsbuiltin.find_files, {})
keyset('n', '<leader>fg', tsbuiltin.live_grep, {})
keyset('n', '<leader>fb', tsbuiltin.buffers, {})
keyset('n', '<leader>fh', tsbuiltin.help_tags, {})

-- Search among words
keyset('n', '<leader>fw', function()
    require("telescope.builtin").live_grep()
end, {})
keyset('n', '<leader>fW', function()
    require("telescope.builtin").live_grep {
        additional_args = function(args)
            return vim.list_extend(args, {"--hidden", "--no-ignore"})
        end
    }
end, {}) -- In ll files

-- ###############################
-- ####### nvim-tree #######
-- ###############################

keyset('n', '<leader>tt', "<cmd>NvimTreeToggle<cr>") -- Open or close the tree. Takes an optional path argument.
keyset('n', '<leader>tf', "<cmd>NvimTreeFocus<cr>") -- Open the tree if it is closed, and then focus on the tree.
keyset('n', '<leader>tc', "<cmd>NvimTreeCollapse<cr>") -- Collapses the nvim-tree recursively.

-- ###############################
-- ####### bufdelete.nvim #######
-- ###############################

keyset("n", "<leader>c", "<cmd>Bdelete<cr>") -- "Close window"

-- ###############################
-- ####### comments.nvim #######
-- ###############################

keyset("n", "<leader>/", function()
    require("Comment.api").toggle.linewise.current()
end)
keyset("v", "<leader>/", "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>")

-- ###############################
-- ####### bufferline.nvim #######
-- ###############################

keyset("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>") -- "Next buffer tab"
keyset("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>") -- "Previous buffer tab"
-- keyset("n", ">b", "<cmd>BufferLineMoveNext<cr>") -- "Move buffer tab right"
-- keyset("n", "<b", "<cmd>BufferLineMovePrev<cr>") -- "Move buffer tab left"

-- ########################
-- ####### coc.nvim #######
-- ########################

-- Use tab for trigger completion with characters ahead and navigate.
-- NOTE: There's always complete item selected by default, you may want to enable
-- no select by `"suggest.noselect": true` in your configuration file.
-- NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
-- other plugin before putting this into your config.
local opts = {
    silent = true,
    noremap = true,
    expr = true
}
keyset("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<TAB>" : coc#refresh()', opts)
keyset("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)

-- Make <CR> to accept selected completion item or notify coc.nvim to format
-- <C-g>u breaks current undo, please make your own choice.
keyset("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)

-- Use <c-j> to trigger snippets
keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
-- Use <c-space> to trigger completion.
keyset("i", "<c-space>", "coc#refresh()", {
    silent = true,
    expr = true
})

-- Use `[g` and `]g` to navigate diagnostics
-- Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", {
    silent = true
})
keyset("n", "]g", "<Plug>(coc-diagnostic-next)", {
    silent = true
})

-- GoTo code navigation.
keyset("n", "gd", "<Plug>(coc-definition)", {
    silent = true
})
keyset("n", "gy", "<Plug>(coc-type-definition)", {
    silent = true
})
keyset("n", "gi", "<Plug>(coc-implementation)", {
    silent = true
})
keyset("n", "gr", "<Plug>(coc-references)", {
    silent = true
})

-- Use K to show documentation in preview window.
function _G.show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
        vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
        vim.fn.CocActionAsync('doHover')
    else
        vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
end
keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', {
    silent = true
})

-- Formatting selected code.
keyset("x", "<leader>f", "<Plug>(coc-format-selected)", {
    silent = true
})
keyset("n", "<leader>f", "<Plug>(coc-format-selected)", {
    silent = true
})

-- Applying codeAction to the selected region.
-- Example: `<leader>aap` for current paragraph
local opts = {
    silent = true,
    nowait = true
}
keyset("x", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)
keyset("n", "<leader>a", "<Plug>(coc-codeaction-selected)", opts)

-- Remap keys for applying codeAction to the current buffer.
keyset("n", "<leader>ac", "<Plug>(coc-codeaction)", opts)

-- Apply AutoFix to problem on the current line.
keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", opts)

-- Run the Code Lens action on the current line.
keyset("n", "<leader>cl", "<Plug>(coc-codelens-action)", opts)

-- Map function and class text objects
-- NOTE: Requires 'textDocument.documentSymbol' support from the language server.
keyset("x", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("o", "if", "<Plug>(coc-funcobj-i)", opts)
keyset("x", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("o", "af", "<Plug>(coc-funcobj-a)", opts)
keyset("x", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("o", "ic", "<Plug>(coc-classobj-i)", opts)
keyset("x", "ac", "<Plug>(coc-classobj-a)", opts)
keyset("o", "ac", "<Plug>(coc-classobj-a)", opts)

-- Remap <C-f> and <C-b> for scroll float windows/popups.
---@diagnostic disable-next-line: redefined-local
local opts = {
    silent = true,
    nowait = true,
    expr = true
}
keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)
keyset("i", "<C-f>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
keyset("i", "<C-b>", 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
keyset("v", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
keyset("v", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts)

-- Use CTRL-S for selections ranges.
-- Requires 'textDocument/selectionRange' support of language server.
keyset("n", "<C-s>", "<Plug>(coc-range-select)", {
    silent = true
})
keyset("x", "<C-s>", "<Plug>(coc-range-select)", {
    silent = true
})

-- Mappings for CoCList
-- code actions and coc stuff
-- @diagnostic disable-next-line: redefined-local
local opts = {
    silent = true,
    nowait = true
}

-- Show all diagnostics. TOREVIEW
keyset("n", ",a", ":<C-u>CocList diagnostics<cr>", opts)
-- Manage extensions.
keyset("n", ",e", ":<C-u>CocList extensions<cr>", opts)
-- Show commands.
keyset("n", ",c", ":<C-u>CocList commands<cr>", opts)
-- Find symbol of current document.
keyset("n", ",o", ":<C-u>CocList outline<cr>", opts)
-- Search workspace symbols.
keyset("n", ",s", ":<C-u>CocList -I symbols<cr>", opts)
-- Do default action for next item.
keyset("n", ",j", ":<C-u>CocNext<cr>", opts)
-- Do default action for previous item.
keyset("n", ",k", ":<C-u>CocPrev<cr>", opts)
-- Resume latest coc list.
keyset("n", ",p", ":<C-u>CocListResume<cr>", opts)
