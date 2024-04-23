local source = {}

function source.new()
  return source
end

function source:is_available() return vim.bo.filetype == "gitcommit" end

function source:get_keyword_pattern() return [[\w\+]] end

local function candidates(entries)
  local items = {}
  for k, v in ipairs(entries) do
    items[k] = {
      label = v.label,
      kind = require('cmp').lsp.CompletionItemKind.Operator,
      documentation = v.documentation,
    }
  end
  return items
end

function source:complete(request, callback)
  if request.context.option.reason == "manual" and request.context.cursor.row ==
      1 and request.context.cursor.col == 1 then
    callback({items = candidates(self.types), isIncomplete = true})
  elseif request.context.option.reason == "auto" and request.context.cursor.row ==
      1 and request.context.cursor.col == 2 then
    callback({items = candidates(self.types), isIncomplete = true})
  elseif request.context.cursor_after_line == ")" and request.context.cursor.row ==
      1 then
    callback({items = candidates(self.scopes), isIncomplete = true})
  else
    callback()
  end
end

return source
