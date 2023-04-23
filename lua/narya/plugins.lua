local plugins = {}

plugins.list = {
  -- Packer
  {
    "wbthomason/packer.nvim",
  },
  -- LSP
  {
    "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason.nvim",
  },
  {
    "williamboman/mason-lspconfig.nvim",
  },
  -- DAP
  { "mfussenegger/nvim-dap" },
  { "mfussenegger/nvim-dap-python",
    run = "~/.config/nvim/venv/bin/pip install debugpy"
  },
  { "mxsdev/nvim-dap-vscode-js" },
  {
    "microsoft/vscode-js-debug",
    opt = true,
    run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out" 
  },
  { "rcarriga/nvim-dap-ui" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "nvim-telescope/telescope-dap.nvim" },
  -- Snippets
  {
    "rafamadriz/friendly-snippets",
  },
  -- CMP
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "hrsh7th/cmp-buffer",
  },
  {
    "hrsh7th/cmp-path",
  },
  {
    "hrsh7th/cmp-cmdline",
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
  },
  {
    "L3MON4D3/LuaSnip",
  },
  {
    "hrsh7th/nvim-cmp",
  },
  {
    "saadparwaiz1/cmp_luasnip",
  },
  -- null-ls
  {
    "jose-elias-alvarez/null-ls.nvim",
  },
  {
    "jayp0521/mason-null-ls.nvim",
  },
  {
    "nvim-lualine/lualine.nvim",
    requires = {
      "kyazdani42/nvim-web-devicons",
    },
  },
  {
    "akinsho/bufferline.nvim",
    tag = "v2.*",
    requires = "kyazdani42/nvim-web-devicons",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({
        with_sync = true,
      })
      ts_update()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context"
  },
  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.x",
    requires = {
      {
        "nvim-lua/plenary.nvim",
      },
    },
  },
  {
    "nvim-telescope/telescope-symbols.nvim",
  },
  {
    "nvim-telescope/telescope-project.nvim",
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    run =
    "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
  },
  -- Git
  {
    "TimUntersberger/neogit",
    requires = "nvim-lua/plenary.nvim",
    ccommit = "71651625b0cccb95bd1ae152d26bcf26d96e5182",
  },
  -- Misc
  {
    "folke/tokyonight.nvim",
  },
  {
    "goolord/alpha-nvim",
    requires = {
      "kyazdani42/nvim-web-devicons",
    },
  },
  {
    "folke/zen-mode.nvim",
  },
  {
    "ggandor/leap.nvim",
  },
  {
    "rcarriga/nvim-notify",
  },

  {
    "lukas-reineke/indent-blankline.nvim",
  },
  {
    "numToStr/Comment.nvim",
  },
  {
    "windwp/nvim-autopairs",
  },
  {
    "ur4ltz/surround.nvim",
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    { "johmsalas/text-case.nvim" },
  },
  {"MunifTanjim/nui.nvim"}
}

-- https://github.com/wbthomason/packer.nvim#bootstrapping
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({
      "git",
      "clone",
      "--depth",
      "1",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

function plugins.load(list)
  -- Loading plugins
  local packer_available, packer = pcall(require, "packer")
  if not packer_available then
    print("Skipping loading plugins until Packer is installed")
    return
  end
  local status_ok, _ = xpcall(function()
    packer.reset()
    packer.startup(function(use)
      for _, plugin in ipairs(list) do
        use(plugin)
      end

      if packer_bootstrap then
        require("packer").sync()
      end
    end)
  end, debug.traceback)

  if not status_ok then
    print("problems detected while loading plugins' configurations")
    print(debug.traceback())
  end
end

return plugins
