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
	clear = true,
})
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.html" },
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
	group = group,
})

-- Autofocus current file in NeovimTree

-- vim.api.nvim_create_autocmd("BufEnter", {
--     pattern = {"*"},
--     callback = function()
--         vim.cmd "NvimTreeFindFile"
--     end,
--     group = group
-- })

-- Writer plugin

function center_window()
	-- vim.opt_local.columns = 100

	if vim.fn.winwidth("%") < 120 then
		return
	end

	local lrwidth = (vim.fn.winwidth("%") - 100) / 2

	local v = vim.api
	config = {
		leftpad = lrwidth,
		rightpad = lrwidth,
	}

	-- Get reference to current_buffer
	local main_win = v.nvim_get_current_win()

	-- get the user's current options for split directions
	local useropts = {
		splitbelow = vim.o.splitbelow,
		splitright = vim.o.splitright,
	}

	-- Make sure that the user doesn't have more than one window/buffer open at the moment
	if #v.nvim_tabpage_list_wins(0) > 1 then
		print("Please only have one window and buffer open")
		return
	end

	-- create scratch window to the left
	vim.o.splitright = false
	vim.cmd(string.format("%svnew", config.leftpad))
	local leftpad = v.nvim_get_current_buf()
	v.nvim_buf_set_name(leftpad, "leftpad")
	v.nvim_buf_set_option(leftpad, "modifiable", false)
	v.nvim_buf_set_option(leftpad, "buflisted", false)
	v.nvim_set_current_win(main_win)

	-- create scratch window to the right
	vim.o.splitright = true
	vim.cmd(string.format("%svnew", config.rightpad))
	local rightpad = v.nvim_get_current_buf()
	v.nvim_buf_set_name(rightpad, "rightpad")
	v.nvim_buf_set_option(rightpad, "modifiable", false)
	v.nvim_buf_set_option(rightpad, "buflisted", false)
	v.nvim_set_current_win(main_win)

	-- keep track of the current state of the plugin
	vim.g.center_buf_enabled = true

	-- reset the user's split opts
	vim.o.splitbelow = useropts.splitbelow
	vim.o.splitright = useropts.splitright

	-- vim.opt.guifont = {"JetBrainsMono Nerd Font Mono", "h52"}
end

-- vim.api.nvim_create_autocmd("BufEnter", {
--     pattern = {"*.md"},
--     callback = center_window,
--     group = group
-- })

-- vim.api.nvim_create_autocmd("VimResized", {
--     pattern = {"*.md"},
--     callback = center_window,
--     group = group
-- })
