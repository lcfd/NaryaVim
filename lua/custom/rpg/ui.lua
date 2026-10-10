-- Three-pane modal: random tables (1), results (2), dice (3).
local tables = require("custom.rpg.tables")
local dice = require("custom.rpg.dice")

local M = {}

local api = vim.api
local ns = api.nvim_create_namespace("rpg_toolkit")
local ALL = "All"
local MAX_ENTRIES = 200

-- Kept across openings, for the whole session.
local state = {
  results = {}, -- { label, value }, newest first
  rolls = {}, -- { notation, total, detail }, newest first
  category = ALL,
  filter = "",
  notation = "",
  history = {}, -- notation history, oldest first
  counts = {}, -- dice spec -> number of dice
}

local SECTIONS = {
  filter = "left",
  list = "left",
  results = "center",
  dice = "right",
  notation = "right",
  rolls = "right",
}

-- The open modal, or nil.
local ui

local function setup_highlights()
  local function set(name, opts)
    opts.default = true
    api.nvim_set_hl(0, name, opts)
  end
  set("RpgHeader", { link = "Title" })
  set("RpgBorderActive", { link = "Special" })
  set("RpgTitleActive", { link = "Special" })
  set("RpgCategory", { link = "Comment" })
  set("RpgCategoryActive", { link = "TabLineSel" })
  set("RpgLabel", { link = "Function" })
  set("RpgMatch", { link = "Special" })
  set("RpgDim", { link = "Comment" })
  set("RpgTotal", { link = "Number" })
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "RPG" })
end

local function copy(text)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  notify("Copied: " .. (text:gsub("\n", " ⏎ ")))
end

local function valid(name)
  return ui and ui.wins[name] and api.nvim_win_is_valid(ui.wins[name])
end

local function set_lines(buf, lines)
  vim.bo[buf].modifiable = true
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
end

local function cursor_line(name)
  return api.nvim_win_get_cursor(ui.wins[name])[1]
end

local function set_cursor(name, line)
  if valid(name) then
    local count = api.nvim_buf_line_count(ui.bufs[name])
    api.nvim_win_set_cursor(ui.wins[name], { math.max(1, math.min(line, count)), 0 })
  end
end

--
-- Layout
--

local TITLE = "RPG Toolkit"

-- Keys shown in each pane's footer (in priority order) and in its `?` help.
local WIN_META = {
  filter = {
    title = " Filter ",
    keys = { { "<CR>", "roll" }, { "<C-n>/<C-p>", "select" }, { "<Tab>", "category" }, { "<Esc>", "back" } },
  },
  list = {
    title = " [1] Tables ",
    keys = { { "<CR>", "roll" }, { "<Tab>", "category" }, { "/", "filter" }, { "R", "reload tables" } },
  },
  results = {
    title = " [2] Results ",
    keys = {
      { "y", "copy" },
      { "p/P", "insert after/before cursor" },
      { "Y", "copy with table name" },
      { "d", "delete" },
      { "C", "clear all" },
    },
  },
  dice = {
    title = " [3] Dice ",
    keys = { { "<CR>", "roll" }, { "+/-", "dice count" }, { "i", "type notation" }, { "<Tab>", "go to rolls" } },
  },
  notation = {
    title = " Roll (e.g. 2d10 + 3d6) ",
    keys = { { "<CR>", "roll" }, { "<Up>/<Down>", "history" }, { "<Esc>", "back" } },
  },
  rolls = {
    title = " Rolls ",
    keys = { { "y", "copy" }, { "Y", "copy total" }, { "d", "delete" }, { "C", "clear all" } },
  },
}

local COMMON_KEYS = { { "1 / 2 / 3", "go to tables / results / dice" }, { "?", "help" }, { "q / <Esc>", "close" } }

--- Joins as many key hints as fit in `width`, ending with "? help" when some are left out.
local function fit_footer(keys, width)
  local items = vim.tbl_map(function(k)
    return k[1] .. " " .. k[2]
  end, keys)
  local full = " " .. table.concat(items, " · ") .. " "
  if vim.fn.strdisplaywidth(full) <= width then
    return full
  end
  local out = {}
  for _, item in ipairs(items) do
    local candidate = vim.list_extend(vim.list_slice(out), { item, "? help" })
    if vim.fn.strdisplaywidth(" " .. table.concat(candidate, " · ") .. " ") > width then
      break
    end
    out[#out + 1] = item
  end
  out[#out + 1] = "? help"
  return " " .. table.concat(out, " · ") .. " "
end

local function layout()
  local cols = vim.o.columns
  local avail = vim.o.lines - vim.o.cmdheight
  local W = math.max(60, math.floor(cols * 0.9))
  local H = math.max(15, math.floor(avail * 0.85))
  local top = math.max(0, math.floor((avail - H) / 2))
  local col = math.max(0, math.floor((cols - W) / 2))

  -- The first row holds the header, the panes go below it
  local row = top + 1
  H = H - 1

  local lw = math.floor(W * 0.3)
  local rw = math.floor(W * 0.3)
  local cw = W - lw - rw
  local dice_h = math.min(#ui.dice, math.max(3, math.floor((H - 3) / 2) - 2))

  local function win(name, r, c, w, h)
    local width = math.max(1, w - 2)
    return {
      relative = "editor",
      row = r,
      col = c,
      width = width,
      height = math.max(1, h),
      border = "rounded",
      title = WIN_META[name].title,
      title_pos = "center",
      footer = fit_footer(WIN_META[name].keys, width),
      footer_pos = "center",
    }
  end
  return {
    header = { relative = "editor", row = top, col = col, width = W, height = 1 },
    filter = win("filter", row, col, lw, 1),
    list = win("list", row + 3, col, lw, H - 5),
    results = win("results", row, col + lw, cw, H - 2),
    dice = win("dice", row, col + lw + cw, rw, dice_h),
    notation = win("notation", row + dice_h + 2, col + lw + cw, rw, 1),
    rolls = win("rolls", row + dice_h + 5, col + lw + cw, rw, H - dice_h - 7),
  }
end

local function render_header()
  local buf, win = ui.header.buf, ui.header.win
  if not api.nvim_win_is_valid(win) then
    return
  end
  local width = api.nvim_win_get_width(win)
  local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(TITLE)) / 2))
  set_lines(buf, { string.rep(" ", pad) .. TITLE })
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  api.nvim_buf_set_extmark(buf, ns, 0, pad, { end_col = pad + #TITLE, hl_group = "RpgHeader" })
end

local function highlight_focus()
  if not ui then
    return
  end
  local current = api.nvim_get_current_win()
  local active
  for name, win in pairs(ui.wins) do
    if win == current then
      active = SECTIONS[name]
    end
  end
  for name, win in pairs(ui.wins) do
    if api.nvim_win_is_valid(win) then
      local hl = "Normal:NormalFloat"
      if SECTIONS[name] == active then
        hl = hl .. ",FloatBorder:RpgBorderActive,FloatTitle:RpgTitleActive"
      end
      vim.wo[win].winhighlight = hl
    end
  end
end

--
-- Rendering
--

local function categories()
  local list = { ALL }
  vim.list_extend(list, ui.engine.categories)
  return list
end

local function category_bar()
  local cats = categories()
  local width = api.nvim_win_get_width(ui.wins.list)
  local esc = function(s)
    return (s:gsub("%%", "%%%%"))
  end

  local parts, len = {}, 0
  for _, c in ipairs(cats) do
    local hl = c == state.category and "RpgCategoryActive" or "RpgCategory"
    parts[#parts + 1] = "%#" .. hl .. "# " .. esc(c) .. " %*"
    len = len + vim.fn.strdisplaywidth(c) + 2
  end
  if len <= width then
    return table.concat(parts)
  end
  -- Too many categories: show only the active one
  local idx = vim.fn.index(cats, state.category) + 1
  return ("%%#RpgCategoryActive# ‹ %s › %%#RpgDim# %d/%d"):format(esc(state.category), idx, #cats)
end

local function visible_tables()
  local pool = vim.tbl_filter(function(t)
    return not t.hidden and (state.category == ALL or t.category == state.category)
  end, ui.engine.tables)
  if state.filter == "" then
    return pool, {}
  end
  local candidates = {}
  for i, t in ipairs(pool) do
    candidates[i] = { name = t.name, idx = i }
  end
  local matched = vim.fn.matchfuzzypos(candidates, state.filter, { key = "name" })
  local items = vim.tbl_map(function(c)
    return pool[c.idx]
  end, matched[1])
  return items, matched[2]
end

local function render_list()
  if not valid("list") then
    return
  end
  local buf = ui.bufs.list
  local items, positions = visible_tables()
  ui.items = items

  local lines = {}
  for i, t in ipairs(items) do
    lines[i] = "  " .. t.name
  end
  if #items == 0 then
    if ui.engine.missing then
      lines = { "  Folder not found:", "  " .. ui.engine.dir }
    elseif #ui.engine.tables == 0 then
      lines = { "  No tables in:", "  " .. ui.engine.dir }
    else
      lines = { "  No matches" }
    end
  end
  set_lines(buf, lines)

  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if #items == 0 then
    for i = 1, #lines do
      api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #lines[i], hl_group = "RpgDim" })
    end
  end
  for i, t in ipairs(items) do
    for _, charpos in ipairs(positions[i] or {}) do
      local byte = vim.fn.byteidx(t.name, charpos) + 2
      local next_byte = vim.fn.byteidx(t.name, charpos + 1) + 2
      api.nvim_buf_set_extmark(buf, ns, i - 1, byte, { end_col = next_byte, hl_group = "RpgMatch" })
    end
    if state.category == ALL then
      api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { virt_text = { { t.category, "RpgDim" } }, virt_text_pos = "eol" })
    end
  end

  vim.wo[ui.wins.list].winbar = category_bar()
  set_cursor("list", 1)
end

--- Renders a newest-first list of entries ({ text = string, ... }); `decorate` adds extmarks per line.
local function render_entries(name, entries, empty, decorate)
  if not valid(name) then
    return
  end
  local buf = ui.bufs[name]
  local lines, map = {}, {}
  for idx, entry in ipairs(entries) do
    for _, l in ipairs(vim.split(entry.text, "\n", { plain = true })) do
      lines[#lines + 1] = l
      map[#lines] = idx
    end
  end
  if #entries == 0 then
    lines = { empty }
  end
  set_lines(buf, lines)
  ui.maps[name] = map

  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  if #entries == 0 then
    api.nvim_buf_set_extmark(buf, ns, 0, 0, { end_col = #empty, hl_group = "RpgDim" })
    return
  end
  local first = {}
  for line, idx in pairs(map) do
    if not first[idx] or line < first[idx] then
      first[idx] = line
    end
  end
  for line, idx in pairs(map) do
    decorate(buf, line - 1, entries[idx], line == first[idx])
  end
end

local function render_results()
  local entries = vim.tbl_map(function(r)
    return { text = r.value, label = r.label }
  end, state.results)
  local label_width = 0
  for _, e in ipairs(entries) do
    label_width = math.max(label_width, vim.fn.strdisplaywidth(e.label))
  end
  label_width = math.min(label_width, 20)
  render_entries("results", entries, "Roll a table to see results here", function(buf, row, entry, is_first)
    local label = is_first and entry.label or ""
    if vim.fn.strdisplaywidth(label) > label_width then
      label = vim.fn.strcharpart(label, 0, label_width - 1) .. "…"
    end
    local pad = math.max(0, label_width - vim.fn.strdisplaywidth(label))
    api.nvim_buf_set_extmark(buf, ns, row, 0, {
      virt_text = { { label .. string.rep(" ", pad), "RpgLabel" }, { is_first and " › " or "   ", "RpgDim" } },
      virt_text_pos = "inline",
      right_gravity = false,
    })
  end)
end

local function render_rolls()
  local entries = vim.tbl_map(function(r)
    return { text = r.notation .. " = " .. r.total, roll = r }
  end, state.rolls)
  render_entries("rolls", entries, "No rolls yet", function(buf, row, entry)
    local text = entry.text
    local start = #text - #tostring(entry.roll.total)
    api.nvim_buf_set_extmark(buf, ns, row, start, { end_col = #text, hl_group = "RpgTotal" })
    if entry.roll.detail ~= tostring(entry.roll.total) then
      api.nvim_buf_set_extmark(buf, ns, row, 0, {
        virt_lines = { { { "  " .. entry.roll.detail, "RpgDim" } } },
      })
    end
  end)
end

local function dice_expr(spec)
  local count = state.counts[spec] or 1
  return (count > 1 and count or "") .. spec
end

local function render_dice()
  if not valid("dice") then
    return
  end
  local lines = vim.tbl_map(function(spec)
    return "  " .. dice_expr(spec)
  end, ui.dice)
  set_lines(ui.bufs.dice, lines)
end

--
-- Actions
--

local function push(list, entry)
  table.insert(list, 1, entry)
  while #list > MAX_ENTRIES do
    table.remove(list)
  end
end

local function roll_table(t)
  if not t then
    return
  end
  local ok, values = pcall(ui.engine.generate, ui.engine, t)
  if not ok then
    notify("Failed to roll " .. t.name .. ": " .. values, vim.log.levels.ERROR)
    return
  end
  if #values == 0 then
    notify(t.name .. " is empty", vim.log.levels.WARN)
    return
  end
  for i = #values, 1, -1 do
    push(state.results, { label = t.name, value = values[i] })
  end
  render_results()
  set_cursor("results", 1)
end

local function roll_dice(expr)
  local result, err = dice.roll(expr)
  if not result then
    notify(err, vim.log.levels.WARN)
    return false
  end
  push(state.rolls, result)
  render_rolls()
  set_cursor("rolls", 1)
  return true
end

local function entry_under_cursor(name, list)
  local idx = ui.maps[name] and ui.maps[name][cursor_line(name)]
  return idx, idx and list[idx]
end

local function focus(name, insert)
  if not valid(name) then
    return
  end
  vim.cmd.stopinsert()
  api.nvim_set_current_win(ui.wins[name])
  if insert then
    vim.cmd("startinsert!")
  end
end

local function input_text(name)
  return vim.trim(table.concat(api.nvim_buf_get_lines(ui.bufs[name], 0, -1, false), " "))
end

local function set_input(name, text)
  api.nvim_buf_set_lines(ui.bufs[name], 0, -1, false, { text })
  if api.nvim_get_current_win() == ui.wins[name] then
    api.nvim_win_set_cursor(ui.wins[name], { 1, #text })
  end
end

function M.close()
  if not ui then
    return
  end
  local current = ui
  ui = nil
  pcall(api.nvim_del_augroup_by_id, current.group)
  vim.cmd.stopinsert()
  for _, win in pairs(vim.list_extend(vim.tbl_values(current.wins), { current.header.win })) do
    if api.nvim_win_is_valid(win) then
      api.nvim_win_close(win, true)
    end
  end
end

local function cycle_category(delta)
  local cats = categories()
  local idx = vim.fn.index(cats, state.category) + 1
  state.category = cats[(idx - 1 + delta) % #cats + 1]
  render_list()
end

--
-- Keymaps
--

local function map(name, modes, lhs, fn, desc)
  vim.keymap.set(modes, lhs, fn, { buffer = ui.bufs[name], nowait = true, silent = true, desc = "[RPG] " .. desc })
end

local function common_maps(name)
  map(name, "n", "1", function()
    focus("list")
  end, "Go to tables")
  map(name, "n", "2", function()
    focus("results")
  end, "Go to results")
  map(name, "n", "3", function()
    -- Pressing 3 again toggles between the dice list and the rolls history
    focus(name == "dice" and "rolls" or "dice")
  end, "Go to dice")
  map(name, "n", "q", M.close, "Close")
  map(name, "n", "<Esc>", M.close, "Close")
  map(name, "n", "?", function()
    local keys = vim.list_extend(vim.list_slice(WIN_META[name].keys), COMMON_KEYS)
    local width = 0
    for _, k in ipairs(keys) do
      width = math.max(width, vim.fn.strdisplaywidth(k[1]))
    end
    local lines = vim.tbl_map(function(k)
      return k[1] .. string.rep(" ", width - vim.fn.strdisplaywidth(k[1]) + 2) .. k[2]
    end, keys)
    notify(table.concat(lines, "\n"))
  end, "Help")
end

local function entry_maps(name, list, render, copy_full)
  map(name, "n", "y", function()
    local _, entry = entry_under_cursor(name, list())
    if entry then
      copy(copy_full(entry, false))
    end
  end, "Copy entry")
  map(name, "n", "<CR>", function()
    local _, entry = entry_under_cursor(name, list())
    if entry then
      copy(copy_full(entry, false))
    end
  end, "Copy entry")
  map(name, "n", "Y", function()
    local _, entry = entry_under_cursor(name, list())
    if entry then
      copy(copy_full(entry, true))
    end
  end, "Copy entry with label")
  map(name, "x", "y", '"+y', "Copy selection")
  local function delete()
    local idx = entry_under_cursor(name, list())
    if idx then
      local line = cursor_line(name)
      table.remove(list(), idx)
      render()
      set_cursor(name, line)
    end
  end
  map(name, "n", "d", delete, "Delete entry")
  map(name, "n", "x", delete, "Delete entry")
  map(name, "n", "C", function()
    local l = list()
    for i = #l, 1, -1 do
      l[i] = nil
    end
    render()
  end, "Clear all")
end

local function setup_maps()
  for name in pairs(ui.bufs) do
    common_maps(name)
  end

  -- Tables list
  local function selected_table()
    return ui.items[cursor_line("list")]
  end
  map("list", "n", "<CR>", function()
    roll_table(selected_table())
  end, "Roll table")
  for _, lhs in ipairs({ "<Tab>", "l", "]" }) do
    map("list", "n", lhs, function()
      cycle_category(1)
    end, "Next category")
  end
  for _, lhs in ipairs({ "<S-Tab>", "h", "[" }) do
    map("list", "n", lhs, function()
      cycle_category(-1)
    end, "Previous category")
  end
  for _, lhs in ipairs({ "/", "i", "a" }) do
    map("list", "n", lhs, function()
      focus("filter", true)
    end, "Filter tables")
  end
  map("list", "n", "R", function()
    ui.engine:reload()
    if not vim.tbl_contains(categories(), state.category) then
      state.category = ALL
    end
    render_list()
    notify("Tables reloaded")
  end, "Reload tables")

  -- Filter input (TextChangedI can lag behind fast typing, so sync before acting)
  local function sync_filter()
    local text = input_text("filter")
    if text ~= state.filter then
      state.filter = text
      render_list()
    end
  end
  map("filter", "i", "<CR>", function()
    sync_filter()
    roll_table(selected_table())
  end, "Roll selected table")
  map("filter", "i", "<Esc>", function()
    sync_filter()
    focus("list")
  end, "Back to tables")
  map("filter", "i", "<Tab>", function()
    cycle_category(1)
  end, "Next category")
  map("filter", "i", "<S-Tab>", function()
    cycle_category(-1)
  end, "Previous category")
  for _, lhs in ipairs({ "<C-n>", "<Down>", "<C-j>" }) do
    map("filter", "i", lhs, function()
      sync_filter()
      set_cursor("list", cursor_line("list") + 1)
    end, "Next table")
  end
  for _, lhs in ipairs({ "<C-p>", "<Up>", "<C-k>" }) do
    map("filter", "i", lhs, function()
      sync_filter()
      set_cursor("list", cursor_line("list") - 1)
    end, "Previous table")
  end

  -- Results
  entry_maps(
    "results",
    function()
      return state.results
    end,
    render_results,
    function(entry, with_label)
      return with_label and (entry.label .. ": " .. entry.value) or entry.value
    end
  )
  -- Insert the result in the buffer the modal was opened from, then close
  local function insert_result(after)
    local _, entry = entry_under_cursor("results", state.results)
    if not entry then
      return
    end
    local origin = ui.origin
    M.close()
    if not api.nvim_win_is_valid(origin) then
      notify("The original window is gone", vim.log.levels.WARN)
      return
    end
    api.nvim_set_current_win(origin)
    if not vim.bo[api.nvim_win_get_buf(origin)].modifiable then
      notify("Buffer is not modifiable", vim.log.levels.WARN)
      return
    end
    api.nvim_put(vim.split(entry.value, "\n", { plain = true }), "c", after, true)
  end
  map("results", "n", "p", function()
    insert_result(true)
  end, "Insert after cursor")
  map("results", "n", "P", function()
    insert_result(false)
  end, "Insert before cursor")

  -- Dice list
  local function selected_spec()
    return ui.dice[cursor_line("dice")]
  end
  map("dice", "n", "<CR>", function()
    roll_dice(dice_expr(selected_spec()))
  end, "Roll dice")
  local function change_count(delta)
    local spec = selected_spec()
    state.counts[spec] = math.max(1, math.min(99, (state.counts[spec] or 1) + delta))
    render_dice()
  end
  for _, lhs in ipairs({ "+", "=", "l", "<Right>" }) do
    map("dice", "n", lhs, function()
      change_count(1)
    end, "More dice")
  end
  for _, lhs in ipairs({ "-", "_", "h", "<Left>" }) do
    map("dice", "n", lhs, function()
      change_count(-1)
    end, "Fewer dice")
  end
  map("dice", "n", "<Tab>", function()
    focus("rolls")
  end, "Go to rolls")
  map("rolls", "n", "<Tab>", function()
    focus("dice")
  end, "Go to dice")
  for _, lhs in ipairs({ "i", "a", "/" }) do
    map("dice", "n", lhs, function()
      focus("notation", true)
    end, "Type dice notation")
  end

  -- Notation input
  map("notation", "i", "<CR>", function()
    local text = input_text("notation")
    if text == "" then
      return
    end
    if roll_dice(text) then
      if state.history[#state.history] ~= text then
        table.insert(state.history, text)
      end
      ui.history_idx = #state.history + 1
      set_input("notation", "")
      state.notation = ""
    end
  end, "Roll notation")
  map("notation", "i", "<Esc>", function()
    focus("dice")
  end, "Back to dice")
  map("notation", "i", "<Up>", function()
    if ui.history_idx > 1 then
      ui.history_idx = ui.history_idx - 1
      set_input("notation", state.history[ui.history_idx])
    end
  end, "Previous expression")
  map("notation", "i", "<Down>", function()
    if ui.history_idx <= #state.history then
      ui.history_idx = ui.history_idx + 1
      set_input("notation", state.history[ui.history_idx] or "")
    end
  end, "Next expression")

  -- Rolls
  entry_maps(
    "rolls",
    function()
      return state.rolls
    end,
    render_rolls,
    function(entry, total_only)
      if total_only then
        return tostring(entry.total)
      end
      local text = entry.notation .. " = " .. entry.total
      if entry.detail ~= tostring(entry.total) then
        text = text .. " " .. entry.detail
      end
      return text
    end
  )
end

--
-- Open
--

local function setup_autocmds()
  local group = ui.group
  local function is_ours(win)
    for _, w in pairs(ui.wins) do
      if w == win then
        return true
      end
    end
    return false
  end

  api.nvim_create_autocmd("WinEnter", {
    group = group,
    callback = function()
      vim.schedule(function()
        if not ui then
          return
        end
        if is_ours(api.nvim_get_current_win()) then
          highlight_focus()
        else
          M.close()
        end
      end)
    end,
  })
  api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function(args)
      if ui and is_ours(tonumber(args.match)) then
        vim.schedule(M.close)
      end
    end,
  })
  api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
      if not ui then
        return
      end
      local configs = layout()
      for name, cfg in pairs(configs) do
        if valid(name) then
          api.nvim_win_set_config(ui.wins[name], cfg)
        end
      end
      if api.nvim_win_is_valid(ui.header.win) then
        api.nvim_win_set_config(ui.header.win, configs.header)
      end
      render_header()
      render_list()
    end,
  })
  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = ui.bufs.filter,
    callback = function()
      local text = input_text("filter")
      if text ~= state.filter then
        state.filter = text
        render_list()
      end
    end,
  })
  api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = ui.bufs.notation,
    callback = function()
      state.notation = input_text("notation")
    end,
  })
end

---@param project { root: string, config: table }
function M.open(project)
  if ui then
    focus("list")
    return
  end
  setup_highlights()

  ui = {
    engine = tables.load(project.root, project.config.tables_dir),
    dice = vim.tbl_map(tostring, project.config.dice),
    wins = {},
    bufs = {},
    maps = {},
    items = {},
    history_idx = #state.history + 1,
    origin = api.nvim_get_current_win(),
    group = api.nvim_create_augroup("RpgToolkitUI", { clear = true }),
  }
  if not vim.tbl_contains(categories(), state.category) then
    state.category = ALL
  end

  local configs = layout()
  local header_buf = api.nvim_create_buf(false, true)
  vim.bo[header_buf].bufhidden = "wipe"
  ui.header = {
    buf = header_buf,
    win = api.nvim_open_win(
      header_buf,
      false,
      vim.tbl_extend("force", configs.header, { style = "minimal", focusable = false, zindex = 60 })
    ),
  }
  vim.wo[ui.header.win].winhighlight = "Normal:NormalFloat"

  for _, name in ipairs({ "filter", "list", "results", "dice", "notation", "rolls" }) do
    local buf = api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].filetype = "rpgtoolkit"
    vim.b[buf].completion = false
    ui.bufs[name] = buf

    local cfg = vim.tbl_extend("force", configs[name], { style = "minimal", zindex = 60 })
    local win = api.nvim_open_win(buf, false, cfg)
    ui.wins[name] = win
    local is_input = name == "filter" or name == "notation"
    vim.wo[win].cursorline = not is_input
    vim.wo[win].wrap = name == "results"
    vim.wo[win].linebreak = name == "results"
    vim.wo[win].breakindent = name == "results"
    vim.bo[buf].modifiable = is_input
  end

  set_input("filter", state.filter)
  set_input("notation", state.notation)
  render_header()
  render_list()
  render_results()
  render_dice()
  render_rolls()
  setup_maps()
  setup_autocmds()

  focus("list")
  highlight_focus()
end

return M
