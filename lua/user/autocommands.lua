-- WIP
local title = "Narya"

local function setf(filetype)
    if vim.fn.did_filetype() == 0 then
        vim.bo.filetype = filetype
    end
end

local function set_filetype(name)
    if type(name) == "string" then
        setf(name)
        return true
    elseif type(name) == "function" then
        local result = name()
        if type(result) == "string" then
            setf(result)
            return true
        end
    end
    return false
end

local group = vim.api.nvim_create_augroup("Narya", {
    clear = true
})
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = {"*.html"},
    callback = function()
        -- vim.notify("Detect the template kind!", "info", {
        --     title = title
        -- })
        -- vim.notify(vim.bo.filetype, "info", { title = title })

        -- vim.notify(vim.bo.filetype, "info", {
        --     title = title
        -- })
        if vim.bo.filetype == "html" then
            -- vim.notify(vim.bo.filetype, "info", { title = title })
            -- vim.bo.filetype = "htmldjango"
            -- vim.bo.filetype = "django-html"
            -- set_filetype("htmldjango")
        end
        if vim.bo.filetype == "htmldjango" then
            -- vim.notify(vim.bo.filetype, "info", { title = title })
            -- vim.bo.filetype = "html"
            -- vim.bo.filetype = "django-html"
            -- set_filetype("htmldjango")
        end
    end,
    group = group
})

-- Autofocus current file in NeovimTree

vim.api.nvim_create_autocmd("BufEnter", {
    pattern = {"*"},
    callback = function()
        vim.cmd "NvimTreeFindFile"
    end,
    group = group
})
