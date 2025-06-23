-- Treesitter movements
-- config_movements

return {
  --
  -- Select
  --
  select = {
    enable = true,
    -- Automatically jump forward to textobj, similar to targets.vim
    lookahead = true,

    keymaps = {
      ["aa"] = { query = "@parameter.outer", desc = "[Treesitter] Select outer part of a parameter/argument." },
      ["ia"] = { query = "@parameter.inner", desc = "[Treesitter] Select inner part of a parameter/argument." },

      ["ai"] = { query = "@conditional.outer", desc = "[Treesitter] Select outer part of a conditional." },
      ["ii"] = { query = "@conditional.inner", desc = "[Treesitter] Select inner part of a conditional." },

      ["al"] = { query = "@loop.outer", desc = "[Treesitter] Select outer part of a loop." },
      ["il"] = { query = "@loop.inner", desc = "[Treesitter] Select inner part of a loop." },

      ["am"] = { query = "@call.outer", desc = "[Treesitter] Select outer part of a function call." },
      ["im"] = { query = "@call.inner", desc = "[Treesitter] Select inner part of a function call." },

      ["af"] = {
        query = "@function.outer",
        desc = "[Treesitter] Select outer part of a method/function definition.",
      },
      ["if"] = {
        query = "@function.inner",
        desc = "[Treesitter] Select inner part of a method/function definition.",
      },

      ["ac"] = { query = "@class.outer", desc = "[Treesitter] Select outer part of a class." },
      ["ic"] = { query = "@class.inner", desc = "[Treesitter] Select inner part of a class." },
    },
  },

  --
  -- Swap
  --
  swap = {
    enable = false,
  },

  --
  -- Move
  --
  move = {
    enable = true,
    set_jumps = true, -- Whether to set jumps in the jumplist.
    goto_next_start = {
      ["]f"] = { query = "@call.outer", desc = "[Treesitter] Next function call start." },
      ["]m"] = { query = "@function.outer", desc = "[Treesitter] Next method/function def start." },
      ["]c"] = { query = "@class.outer", desc = "[Treesitter] Next class start." },
      ["]i"] = { query = "@conditional.outer", desc = "[Treesitter] Next conditional start." },
      ["]l"] = { query = "@loop.outer", desc = "[Treesitter] Next loop start." },

      -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
      -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
      ["]s"] = { query = "@scope", query_group = "locals", desc = "[Treesitter] Next scope." },
      ["]z"] = { query = "@fold", query_group = "folds", desc = "[Treesitter] Next fold." },
    },
    goto_next_end = {
      ["]F"] = { query = "@call.outer", desc = "[Treesitter] Next function call end." },
      ["]M"] = { query = "@function.outer", desc = "[Treesitter] Next method/function def end." },
      ["]C"] = { query = "@class.outer", desc = "[Treesitter] Next class end." },
      ["]I"] = { query = "@conditional.outer", desc = "[Treesitter] Next conditional end." },
      ["]L"] = { query = "@loop.outer", desc = "[Treesitter] Next loop end." },
    },
    goto_previous_start = {
      ["[f"] = { query = "@call.outer", desc = "[Treesitter] Prev function call start." },
      ["[m"] = { query = "@function.outer", desc = "[Treesitter] Prev method/function def start." },
      ["[c"] = { query = "@class.outer", desc = "[Treesitter] Prev class start." },
      ["[i"] = { query = "@conditional.outer", desc = "[Treesitter] Prev conditional start." },
      ["[l"] = { query = "@loop.outer", desc = "[Treesitter] Prev loop start." },
    },
    goto_previous_end = {
      ["[F"] = { query = "@call.outer", desc = "[Treesitter] Prev function call end." },
      ["[M"] = { query = "@function.outer", desc = "[Treesitter] Prev method/function def end." },
      ["[C"] = { query = "@class.outer", desc = "[Treesitter] Prev class end." },
      ["[I"] = { query = "@conditional.outer", desc = "[Treesitter] Prev conditional end." },
      ["[L"] = { query = "@loop.outer", desc = "[Treesitter] Prev loop end." },
    },
  },
}
