-- Subset of Obsidian's search syntax, used by the graph's search filter and
-- color groups: implicit AND, OR, `-` negation, parentheses, "quoted phrases",
-- /regex/ and the path:, file:, tag:, content:, line: and section: operators.
local M = {}

local nfc = require("custom.graph.unicode").nfc

local function key(s)
  return vim.fn.tolower(nfc(s))
end

local function tokenize(input)
  local tokens, i, n = {}, 1, #input
  while i <= n do
    local c = input:sub(i, i)
    if c:match("%s") then
      i = i + 1
    elseif c == "(" or c == ")" then
      tokens[#tokens + 1] = { kind = c }
      i = i + 1
    elseif c == "-" and input:sub(i + 1, i + 1):match("%S") then
      tokens[#tokens + 1] = { kind = "not" }
      i = i + 1
    else
      local op = input:match("^([%a%-]+):", i)
      if op then
        i = i + #op + 1
      end
      local value, kind
      local q = input:sub(i, i)
      if q == '"' then
        local close = input:find('"', i + 1, true) or (n + 1)
        value, kind, i = input:sub(i + 1, close - 1), "text", close + 1
      elseif q == "/" and input:find("/", i + 1, true) then
        local close = input:find("/", i + 1, true)
        value, kind, i = input:sub(i + 1, close - 1), "regex", close + 1
      elseif q == "(" and op then
        -- `path:(a b)`: the operator applies to every term of the group
        tokens[#tokens + 1] = { kind = "opgroup", op = op:lower() }
        goto continue
      else
        local word = input:match("^[^%s%(%)]+", i) or ""
        value, kind, i = word, "text", i + #word
      end
      if not op and kind == "text" and value == "OR" then
        tokens[#tokens + 1] = { kind = "or" }
      elseif value ~= "" then
        tokens[#tokens + 1] = { kind = kind, op = op and op:lower() or nil, value = value }
      end
    end
    ::continue::
  end
  return tokens
end

local function text_matcher(value, kind)
  if kind == "regex" then
    local ok, re = pcall(vim.regex, "\\v\\c" .. value)
    if not ok then
      return function()
        return false
      end
    end
    return function(s)
      return s ~= nil and re:match_str(s) ~= nil
    end
  end
  value = key(value)
  return function(s)
    return s ~= nil and s:find(value, 1, true) ~= nil
  end
end

local function term_predicate(op, value, kind)
  local match = text_matcher(value, kind)
  if op == "path" then
    return function(node)
      return node.path ~= nil and match(key(node.path))
    end
  elseif op == "file" then
    return function(node)
      return node.path ~= nil and match(key(vim.fs.basename(node.path)))
    end
  elseif op == "tag" then
    local tag = key(value):gsub("^#", "")
    return function(node)
      for _, t in ipairs(node.tags or {}) do
        if t == tag or vim.startswith(t, tag .. "/") then
          return true
        end
      end
      return false
    end
  elseif op == "content" or op == "line" or op == "section" or op == "block" then
    return function(_, content)
      return match(content)
    end
  end
  -- plain terms (and unknown operators) match the file name or the content
  return function(node, content)
    return (node.path ~= nil and match(key(vim.fs.basename(node.path)))) or match(content)
  end
end

--- Compiles a query into `predicate(node, content) -> boolean`.
--- Returns nil for an empty query (everything matches).
function M.compile(input)
  local tokens = tokenize(input or "")
  if #tokens == 0 then
    return nil
  end
  local pos = 1
  local parse_or

  local function parse_unary(op)
    local tok = tokens[pos]
    if not tok then
      return nil
    end
    if tok.kind == "not" then
      pos = pos + 1
      local inner = parse_unary(op)
      return inner and function(node, content)
        return not inner(node, content)
      end
    elseif tok.kind == "(" or tok.kind == "opgroup" then
      pos = pos + 1
      local inner = parse_or(tok.op or op)
      if tokens[pos] and tokens[pos].kind == ")" then
        pos = pos + 1
      end
      return inner
    elseif tok.kind == "text" or tok.kind == "regex" then
      pos = pos + 1
      return term_predicate(tok.op or op, tok.value, tok.kind)
    end
    return nil
  end

  local function parse_and(op)
    local parts = {}
    while tokens[pos] and tokens[pos].kind ~= "or" and tokens[pos].kind ~= ")" do
      local p = parse_unary(op)
      if not p then
        pos = pos + 1
      else
        parts[#parts + 1] = p
      end
    end
    if #parts == 0 then
      return nil
    end
    return function(node, content)
      for _, p in ipairs(parts) do
        if not p(node, content) then
          return false
        end
      end
      return true
    end
  end

  parse_or = function(op)
    local parts = { parse_and(op) }
    while tokens[pos] and tokens[pos].kind == "or" do
      pos = pos + 1
      parts[#parts + 1] = parse_and(op)
    end
    parts = vim.tbl_filter(function(p)
      return p ~= nil
    end, parts)
    if #parts == 0 then
      return nil
    end
    return function(node, content)
      for _, p in ipairs(parts) do
        if p(node, content) then
          return true
        end
      end
      return false
    end
  end

  local predicate
  while pos <= #tokens do
    local p = parse_or(nil)
    if p then
      local prev = predicate
      predicate = prev and function(node, content)
        return prev(node, content) and p(node, content)
      end or p
    end
    pos = pos + 1 -- skip a stray ")"
  end
  return predicate
end

--- Returns a set { [node_index] = true } of the files (notes and attachments)
--- matching `input`, or nil when the query is empty.
---@param graph graph.Graph
function M.match(graph, input)
  local predicate = M.compile(input)
  if not predicate then
    return nil
  end
  local result = {}
  for i, node in ipairs(graph.nodes) do
    if node.path and predicate(node, graph.content[node.id] or "") then
      result[i] = true
    end
  end
  return result
end

return M
