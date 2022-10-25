local keyset = vim.keymap.set

local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
if not status_ok then
    return
end

local status_ok, neogit = pcall(require, "neogit")
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

-- Go to the start and the end of a sentence

keyset("n", "<leader>ee", "$", {
    desc = "Go to the end of the line."
})
keyset("n", "<leader>aa", "^", {
    desc = "Go to the start of the line."
})
keyset("n", "<leader>df", "<CMD>lua vim.lsp.buf.format()<CR>", {
    desc = "Format file."
})

-- ##############################
-- ####### telescope.nvim #######
-- ##############################

keyset('n', '<leader>fm', "<CMD>Telescope file_browser<CR>", {
    desc = "Synchronized creation, deletion, renaming, and moving of files and folders."
})
keyset('n', '<leader>ff', tsbuiltin.find_files, {
    desc = "Lists files in your current working directory, respects .gitignore (find_files)."
})
keyset('n', '<leader>fw', tsbuiltin.live_grep, {
    desc = "Live fuzzy search inside of the currently open buffer (current_buffer_fuzzy_find)."
})
keyset('n', '<leader>fg', tsbuiltin.grep_string, {
    desc = "Searches for the string under your cursor in your current working directory (grep_string)."
})
keyset('n', '<leader>fb', tsbuiltin.buffers, {
    desc = "Lists open buffers in current Neovim instance (buffers)."
})
keyset('n', '<leader>fh', tsbuiltin.help_tags, {
    desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore (live_grep)."
})
keyset('n', '<leader>fi', tsbuiltin.current_buffer_fuzzy_find, {
    desc = "Lists available help tags and opens a new window with the relevant help info on."
})
keyset('n', '<leader>fo', tsbuiltin.oldfiles, {
    desc = "Lists previously open files."
})
keyset('n', '<leader>ft', tsbuiltin.treesitter, {
    desc = "Lists Function names, variables, from Treesitter!"
})

-- Git

keyset('n', '<leader>gb', tsbuiltin.git_branches, {
    desc = "Lists all branches with log preview, checkout action <cr>, track action <C-t> and rebase action<C-r>."
})
keyset('n', '<leader>gc', tsbuiltin.git_commits, {
    desc = "Lists git commits with diff preview, checkout action <cr>, reset mixed <C-r>m, reset soft <C-r>s and reset hard <C-r>h."
})
keyset('n', '<leader>gs', tsbuiltin.git_status, {
    desc = "Lists current changes per file with diff preview and add action. (Multi-selection still WIP)"
})

-- LSP

keyset('n', '<leader>lo', tsbuiltin.lsp_document_symbols, {
    desc = "Lists LSP document symbols in the current buffer."
})
keyset('n', '<leader>lr', tsbuiltin.lsp_references, {
    desc = "Lists LSP references for word under the cursor."
})
keyset('n', '<leader>ld', tsbuiltin.lsp_definitions, {
    desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope."
})
keyset('n', '<leader>lp', function()
    tsbuiltin.diagnostics({
        bufnr = 0
    })
end, {
    desc = "Lists Diagnostics for all open buffers or a specific buffer. Use option bufnr=0 for current buffer."
})

-- Project
keyset('n', '<leader>pp', "<CMD>lua require'telescope'.extensions.project.project{}<CR>", {
    desc = "Switch between projects."
})

-- Not working
keyset('n', '<leader>li', tsbuiltin.lsp_implementations, {
    desc = "Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope."
})

-- ###########################
-- ######## nvim-tree ########
-- ###########################

keyset('n', '<leader>tt', "<cmd>NvimTreeToggle<cr>", {
    desc = "Toggle the tree view."
})
keyset('n', '<leader>tf', "<cmd>NvimTreeFocus<cr>", {
    desc = "Focus the tree view."
})
keyset('n', '<leader>tc', "<cmd>NvimTreeCollapse<cr>", {
    desc = "Close the tree view."
})

-- ##############################
-- ####### bufdelete.nvim #######
-- ##############################

keyset("n", "<leader>bc", "<cmd>Bdelete<cr>", {
    desc = "Close gracefully the current buffer."
}) -- "Close window"

-- ###############################
-- ####### comments.nvim #########
-- ###############################

-- Look at lua/user/comment.lua

-- ###############################
-- ####### bufferline.nvim #######
-- ###############################

keyset("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", {
    desc = "Go to the next buffer."
})
keyset("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", {
    desc = "Go to the previous buffer."
})

-- ######################
-- ####### Neogit #######
-- ######################

keyset("n", "<leader>gg", "<cmd>Neogit<cr>", {
    desc = "Open the Git panel."
})
