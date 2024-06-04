local jumpToFile = function(n)
  return function()
    require("harpoon"):list():select(n)
  end
end

return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
  config = function()
    require("harpoon").setup({
      settings = {
        save_on_toggle = true,
      },
    })
  end,
  keys = {
    {
      "=",
      function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end,
      desc = "[Harpoon] Quick menu.",
    },
    {
      "-",
      function()
        require("harpoon"):list():add()
      end,
      desc = "[Harpoon] Add file.",
    },
    {
      "<leader>1",
      jumpToFile(1),
      desc = "[Harpoon] To file 1.",
    },
    {
      "<leader>2",
      jumpToFile(2),
      desc = "[Harpoon] To file 2.",
    },
    {
      "<leader>3",
      jumpToFile(3),
      desc = "[Harpoon] To file 3.",
    },
    {
      "<leader>4",
      jumpToFile(4),
      desc = "[Harpoon] To file 4.",
    },
    {
      "<leader>5",
      jumpToFile(5),
      desc = "[Harpoon] To file 5.",
    },
  },
}
