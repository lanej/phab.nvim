local config = require('phab.config')

local M = {}

M.setup = function(options)
  -- --load the configs
  setmetatable(M, {
    __newindex = config.set,
    __index = config.get,
  })
  -- -- if options provided to setup, override defaults
  if options ~= nil then
    for k, v1 in pairs(options) do
      config.defaults[k] = v1
    end
  end
  -- Verify that configuration values are of the correct type
  config.verify()
end

M.current_revision = function()
  return vim.json.decode(vim.fn.system { "phab", "current-revision" })
end

M.get_quickfix = function()
  local qf = {}
  local revision = M.current_revision()

  local inlines = vim.json.decode(vim.fn.system { "phab", "list-inlines", revision })
  for _, comments in ipairs(inlines) do
    for _, comment in ipairs(comments.comments) do
      local author = comments.author
      if author == nil then author = "unknown" else author = author.username end
      table.insert(qf,
      { filename = comments.path, lnum = comments.line, text = author .. ": " .. comment.content.raw:gsub("\n", "  ") })
    end
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local diff_comments = vim.json.decode(vim.fn.system { "phab", "list-comments", revision })
  for _, comments in ipairs(diff_comments) do
    for _, comment in ipairs(comments.comments) do
      local author = comments.author
      if author == nil then author = "unknown" else author = author.username end
      table.insert(qf, { bufnr = bufnr, text = author .. ": " .. comment.content.raw:gsub("\n", "  ") })
    end
  end

  return qf
end

M.set_inlines = function()
  vim.fn.setqflist(M.get_quickfix())
  vim.api.nvim_command('Trouble quickfix')
end

return M
