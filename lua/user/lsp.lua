local status_ok, mason = pcall(require, "mason")
if not status_ok then
	vim.notify("Problem with mason")
	return
end

local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
	vim.notify("Problem with mason-lspconfig")
	return
end

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
	vim.notify("Problems with lspconfig")
	return
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
	return
end

-- Setup Mason

mason.setup()

-- For Reference
-- https://github.com/artempyanykh/marksman

mason_lspconfig.setup({
	ensure_installed = {
		"sumneko_lua",
		"pyright",
		"html",
		"tsserver",
		"dockerls",
		"yamlls",
		"marksman",
		"jsonls",
		"sqlls",
		"lemminx",
		"taplo",
		"tailwindcss",
	},
	automatic_installation = true,
})

-- Enable LSP
local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

mason_lspconfig.setup_handlers({
	function(server_name)
		if server_name == "tailwindcss" then
			lspconfig[server_name].setup({
				capabilities = capabilities,
				root_dir = lspconfig.util.root_pattern(
					"tailwind.config.js",
					"tailwind.config.ts",
					"postcss.config.js",
					"postcss.config.ts",
					"package.json",
					"node_modules",
					".git",
					"project/theme/static_src/tailwind.config.js",
					"theme/static_src/tailwind.config.js"
				),
			})
		else
			lspconfig[server_name].setup({
				capabilities = capabilities,
			})
		end
	end,
})

-- ########################################
-- ############### HACK ###################
-- ########################################
-- Use Poetry virtualenv in the folder without activating it manually
-- *if* there is no activated virtualenv.

-- TODO: Not really performant, maybe there are better solutions.

local configs = require("lspconfig/configs")
local util = require("lspconfig/util")

local path = util.path

local function get_python_path(workspace)
	-- Use activated virtualenv.
	if vim.env.VIRTUAL_ENV then
		return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
	end

	-- Find and use virtualenv via poetry in workspace directory.
	local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
	if match ~= "" then
		local venv = vim.fn.trim(vim.fn.system("poetry env info -p"))
		return path.join(venv, "bin", "python")
	end

	-- Fallback to system Python.
	return exepath("python3") or exepath("python") or "python"
end

lspconfig.pyright.setup({
	before_init = function(_, config)
		config.settings.python.pythonPath = get_python_path(config.root_dir)
	end,
})
