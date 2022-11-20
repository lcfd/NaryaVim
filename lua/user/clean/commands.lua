local M = {}

function M.setup()
    vim.api.nvim_create_user_command("Cppath", function()
        local path = vim.fn.expand("%:p")
        vim.fn.setreg("+", path)
        vim.notify('Copied "' .. path .. '" to the clipboard!')
    end, {})

    vim.api.nvim_create_user_command("SetDjangoProject", function()
        vim.cmd("au BufNewFile,BufRead *.html set filetype=htmldjango")
    end, {})

    -- TODO: check pyproject if Django is installed -> Lua io.popopen
end

return M
