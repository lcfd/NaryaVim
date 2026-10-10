-- Dice notation parser and roller.
-- Supports sums of terms like `2d10 + 3d6 - 2`, plus per-term modifiers:
--   d% (d100), dF (fudge), ! (exploding), khN / klN (keep highest/lowest N), /a /d (advantage/disadvantage).
local M = {}

local MAX_DICE = 1000
local MAX_SIDES = 100000
local MAX_EXPLOSIONS = 100

local function roll_die(sides)
  if sides == "F" then
    return math.random(-1, 1)
  end
  return math.random(1, sides)
end

local function term_notation(t)
  if t.kind == "const" then
    return tostring(t.value)
  end
  local s = (t.count > 1 and t.count or "") .. "d" .. (t.sides == 100 and t.percent and "%" or t.sides)
  if t.explode then
    s = s .. "!"
  end
  if t.keep then
    s = s .. (t.keep == "high" and "kh" or "kl") .. t.keep_n
  end
  return s
end

--- Parses an expression into a list of terms.
---@return table[]|nil terms, string|nil err
function M.parse(expr)
  local s = vim.trim(expr):lower()
  if s == "" then
    return nil, "empty expression"
  end

  local function skip_spaces(pos)
    local _, e = s:find("^%s*", pos)
    return e + 1
  end

  local terms, pos = {}, 1
  while pos <= #s do
    local sign = 1
    local c = s:sub(pos, pos)
    if c == "+" or c == "-" then
      sign = c == "-" and -1 or 1
      pos = skip_spaces(pos + 1)
    elseif #terms > 0 then
      return nil, "expected + or - before '" .. s:sub(pos) .. "'"
    end
    if pos > #s then
      return nil, "incomplete expression"
    end

    local _, e, count, sides = s:find("^(%d*)d(%d+)", pos)
    if not e then
      _, e, count, sides = s:find("^(%d*)d([%%f])", pos)
    end

    local term
    if e then
      pos = e + 1
      term = {
        kind = "dice",
        sign = sign,
        count = tonumber(count) or 1,
        sides = sides == "%" and 100 or sides == "f" and "F" or tonumber(sides),
        percent = sides == "%",
      }
      -- Modifiers
      while pos <= #s do
        local me, n
        if s:sub(pos, pos) == "!" then
          term.explode = true
          pos = pos + 1
        elseif s:find("^/a", pos) then
          term.keep, term.keep_n, pos = "high", 1, pos + 2
        elseif s:find("^/d", pos) then
          term.keep, term.keep_n, pos = "low", 1, pos + 2
        else
          _, me, n = s:find("^kh(%d*)", pos)
          if me then
            term.keep, term.keep_n, pos = "high", tonumber(n) or 1, me + 1
          else
            _, me, n = s:find("^kl(%d*)", pos)
            if me then
              term.keep, term.keep_n, pos = "low", tonumber(n) or 1, me + 1
            else
              _, me, n = s:find("^k(%d*)", pos)
              if me then
                term.keep, term.keep_n, pos = "high", tonumber(n) or 1, me + 1
              else
                break
              end
            end
          end
        end
      end
      if term.count < 1 or term.count > MAX_DICE then
        return nil, "dice count must be between 1 and " .. MAX_DICE
      end
      if term.sides ~= "F" and (term.sides < 1 or term.sides > MAX_SIDES) then
        return nil, "dice sides must be between 1 and " .. MAX_SIDES
      end
      if term.explode and (term.sides == "F" or term.sides < 2) then
        term.explode = nil
      end
    else
      local _, ce, n = s:find("^(%d+)", pos)
      if not ce then
        return nil, "unexpected '" .. s:sub(pos) .. "'"
      end
      pos = ce + 1
      term = { kind = "const", sign = sign, value = tonumber(n) }
    end
    terms[#terms + 1] = term
    pos = skip_spaces(pos)
  end
  return terms
end

--- Rolls an expression.
---@return { notation: string, total: number, detail: string }|nil, string|nil err
function M.roll(expr)
  local terms, err = M.parse(expr)
  if not terms then
    return nil, err
  end

  local total, notation, detail = 0, {}, {}
  for i, t in ipairs(terms) do
    local op = t.sign < 0 and "-" or "+"
    local value_str
    if t.kind == "const" then
      total = total + t.sign * t.value
      value_str = tostring(t.value)
    else
      local rolls = {}
      for _ = 1, t.count do
        local v = roll_die(t.sides)
        rolls[#rolls + 1] = { v = v, kept = true }
        local n = 0
        while t.explode and v == t.sides and n < MAX_EXPLOSIONS do
          v = roll_die(t.sides)
          rolls[#rolls + 1] = { v = v, kept = true, exploded = true }
          n = n + 1
        end
      end
      if t.keep then
        local sorted = {}
        for idx, r in ipairs(rolls) do
          r.kept = false
          sorted[idx] = r
        end
        table.sort(sorted, function(a, b)
          if t.keep == "high" then
            return a.v > b.v
          end
          return a.v < b.v
        end)
        for k = 1, math.min(t.keep_n, #sorted) do
          sorted[k].kept = true
        end
      end
      local sum, shown = 0, {}
      for _, r in ipairs(rolls) do
        local str = t.sides == "F" and (r.v > 0 and "+" or r.v < 0 and "-" or "0") or tostring(r.v)
        if r.exploded then
          str = "!" .. str
        end
        if r.kept then
          sum = sum + r.v
        else
          str = "(" .. str .. ")"
        end
        shown[#shown + 1] = str
      end
      total = total + t.sign * sum
      value_str = "[" .. table.concat(shown, ", ") .. "]"
    end

    if i == 1 then
      notation[#notation + 1] = (t.sign < 0 and "-" or "") .. term_notation(t)
      detail[#detail + 1] = (t.sign < 0 and "-" or "") .. value_str
    else
      notation[#notation + 1] = op .. " " .. term_notation(t)
      detail[#detail + 1] = op .. " " .. value_str
    end
  end

  return {
    notation = table.concat(notation, " "),
    total = total,
    detail = table.concat(detail, " "),
  }
end

return M
