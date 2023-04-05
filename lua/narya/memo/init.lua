-- ###### Plugin #######
-- MEMO
-- A simple plugin that allows you to see small chunks 
-- of informations that you use frequently.
-- #####################
-- #####################
-- #####################
local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local map = require("narya.utils.map")

local M = {}

function M.setup(config)

    vim.api.nvim_create_user_command("Memos", function()
        local popup = Popup({
            enter = true,
            focusable = true,
            border = {
                style = "rounded",
                text = {
                    top = " Memos ",
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

        -- set content
        vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, config.narya_memo)

        popup:mount()

        -- unmount component when cursor leaves buffer
        popup:on(event.BufLeave, function()
            popup:unmount()
        end)
    end, {})

end

return M
