-- mappings

return function(cmp)
  local mappings = {
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    -- ["<C-d>"] = cmp.mapping.complete(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({
      -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      select = true,
    }),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-j>"] = cmp.mapping(function(_)
      luasnip.jump(1)
    end, {
      "i",
      "s",
    }),
    ["<C-k>"] = cmp.mapping(function(_)
      luasnip.jump(-1)
    end, {
      "i",
      "s",
    }),
  }

  return mappings
end
