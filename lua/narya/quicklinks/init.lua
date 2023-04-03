local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event

local M = {}

function M.setup(config)

    -- mount/open the component
    vim.api.nvim_create_user_command("Links", function()
        local popup = Popup({
            enter = true,
            focusable = true,
            border = {
                style = "rounded",
                text = {
                    top = " Links ",
                    top_align = "center"
                },
                padding = {
                    2,
                    4
                }
            },
            position = "50%",
            size = {
                width = "50%",
                height = "60%"
            },
            buf_options = {
                modifiable = false,
                readonly = true
            }
        })

        popup:map("n", "q", function()
            popup:unmount()
        end)

        popup:mount()

        -- set content
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, {
            "🔗 https://twitter.com/lc_fd",
            "🔗 https://github.com/lcfd?tab=repositories",
            "🔗 https://strawberry.rocks/docs",
            "🔗 https://stackoverflow.com/"
        })

        -- unmount component when cursor leaves buffer
        popup:on(event.BufLeave, function()
            popup:unmount()
        end)
    end, {})

end

return M
