local keyset = vim.keymap.set

local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
if not status_ok then
    return
end

-- ########################
-- ####### Generic ########
-- ########################

-- Avoid press shift to type :
keyset("n", ";", ":")

-- Go to the start and the end of a sentence

keyset("n", "<leader>ee", "$", {
    desc = "Go to the end of the line."
})
keyset("n", "<leader>aa", "^", {
    desc = "Go to the start of the line."
})

-- keyset("n", "<leader>df", vim.lsp.buf.format, {
--     desc = "Format file."
-- })

-- ##############################
-- ####### telescope.nvim #######
-- ##############################

keyset('n', '<leader>fm', "<CMD>Telescope file_browser<CR>", {
    desc = "Synchronized creation, deletion, renaming, and moving of files and folders."
})

keyset('n', '<leader>ff', tsbuiltin.find_files, {
    desc = "Lists files in your current working directory, respects .gitignore (find_files)."
})
keyset('n', '<leader><space>', tsbuiltin.find_files, {
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

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
-- local on_attach = function(_, bufnr)
--     -- NOTE: Remember that lua is a real programming language, and as such it is possible
--     -- to define small helper and utility functions so you don't have to repeat yourself
--     -- many times.
--     --
--     -- In this case, we create a function that lets us more easily define mappings specific
--     -- for LSP related items. It sets the mode, buffer and description for us each time.
--     local nmap = function(keys, func, desc)
--         if desc then
--             desc = 'LSP: ' .. desc
--         end

--         vim.keymap.set('n', keys, func, {
--             buffer = bufnr,
--             desc = desc
--         })
--     end

--     nmap('<leader>rn', vim.lsp.buf.rename, "[R]e[n]ame")
--     nmap("<leader>lr", vim.lsp.buf.rename, "Rename what's under the cursor.")
--     nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

--     -- nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
--     nmap("gd", tsbuiltin.lsp_definitions, "[G]oto [D]efinition")
--     nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
--     nmap("gr", tsbuiltin.lsp_references, "[G]oto [R]eferences")
--     nmap("<leader>ds", tsbuiltin.lsp_document_symbols, "[D]ocument [S]ymbols")
--     nmap("<leader>ws", tsbuiltin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

--     -- See `:help K` for why this keymap
--     nmap("K", vim.lsp.buf.hover, "Hover Documentation")
--     nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

--     -- Lesser used LSP functionality
--     nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
--     nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
--     nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
--     nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
--     nmap("<leader>wl", function()
--         print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--     end, "[W]orkspace [L]ist Folders")

--     -- Create a command `:Format` local to the LSP buffer
--     local formatfunc = function(_)
--         if vim.lsp.buf.format then
--             vim.lsp.buf.format()
--         elseif vim.lsp.buf.formatting then
--             vim.lsp.buf.formatting()
--         end
--     end
--     vim.api.nvim_buf_create_user_command(bufnr, "Format", formatfunc, {
--         desc = "Format current buffer with LSP"
--     })
--     nmap("<leader>df", formatfunc, "Format file.")
-- end

-- keyset('n', '<leader>lo', tsbuiltin.lsp_document_symbols, {
--     desc = "Lists LSP document symbols in the current buffer."
-- })
-- keyset('n', '<leader>lr', tsbuiltin.lsp_references, {
--     desc = "Lists LSP references for word under the cursor."
-- })
-- keyset('n', '<leader>ld', tsbuiltin.lsp_definitions, {
--     desc = "Goto the definition of the word under the cursor, if there's only one, otherwise show all options in Telescope."
-- })

-- ####################################
-- ######## Diagnostic keymaps ########
-- ####################################

keyset('n', '<leader>lk', function()
    tsbuiltin.diagnostics({
        bufnr = 0
    })
end, {
    desc = "Lists Diagnostics for all open buffers or a specific buffer. Use option bufnr=0 for current buffer."
})
keyset('n', '<leader>lj', function()
    vim.diagnostic.open_float(nil, {
        focus = false
    })
end, {
    desc = "Diagnostic of element in hover."
})
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
-- keyset('n', '<leader>lt', vim.lsp.buf.hover, {
--     desc = "Show the details of what is under the cursor."
-- })

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

-- keyset('n', '<leader>tt', "<cmd>NvimTreeToggle<cr>", {
--     desc = "Toggle the tree view."
-- })
-- keyset('n', '<leader>tf', "<cmd>NvimTreeFocus<cr>", {
--     desc = "Focus the tree view."
-- })
-- keyset('n', '<leader>tc', "<cmd>NvimTreeCollapse<cr>", {
--     desc = "Close the tree view."
-- })

-- ##############################
-- ####### Delete buffers #######
-- ##############################

keyset("n", "<leader>xx", "<cmd>bd<cr>", {
    desc = "Close gracefully the current buffer."
}) -- "Close window"
keyset("n", "<leader>xa", "<cmd>%bd|e#<cr>", {
    desc = "Close gracefully the current buffer."
}) -- "Close all buffers apart the current"

-- ###############################
-- ####### comments.nvim #########
-- ###############################

-- Look at lua/user/comment.lua

-- ###############################
-- ####### bufferline.nvim #######
-- ###############################

-- At the moment I consider them really slow
-- I don't have more than 3 buffer opened usually so I can cycle using m

-- ######################
-- ####### Neogit #######
-- ######################

keyset("n", "<leader>gg", "<CMD>Neogit<CR>", {
    desc = "Open the Git panel."
})

-- #####################
-- ####### Quick #######
-- #####################

keyset('i', 'jj', "<Esc>", {
    desc = "Map esc to jj in Insert Mode."
})

keyset("n", "m", "<cmd>BufferLineCycleNext<cr>", {
    desc = "Go to the next buffer."
})
keyset("n", "M", "<cmd>BufferLineCyclePrev<cr>", {
    desc = "Go to the next buffer."
})
