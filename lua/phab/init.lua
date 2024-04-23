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

M.upsert_diff = function()
  M.spawn('arc', { args = { "diff", "origin/master" } },
    {
      stdout = function()
      end,
      stderr = function(data) print(data) end
    },
    function(code) -- we want to call this function when the process is done
      print('child process exited with code ' .. string.format('%d', code))
    end)
end

M.get_quickfix = function()
  local qf = {}
  local revision = M.current_revision()

  local inlines = vim.json.decode(vim.fn.system { "phab", "list-inlines", revision })
  for _, comments in ipairs(inlines) do
    for _, comment in ipairs(comments.comments) do
      local author = comments.author
      if author == nil then author = "bot" else author = author.username end
      table.insert(qf,
        { filename = comments.path, lnum = comments.line, text = author .. ": " .. comment.content.raw:gsub("\n", "  ") })
    end
  end

  return qf
end

M.get_comments = function()
  local comment_data = {}
  local revision = M.current_revision()

  local diff_comments = vim.json.decode(vim.fn.system { "phab", "list-comments", revision })
  for _, comments in ipairs(diff_comments) do
    for _, comment in ipairs(comments.comments) do
      local author = comments.author
      if author == nil then author = "bot" else author = author.username end
      table.insert(comment_data, { created_at = comment.created_at, author = author, comment = comment.content.raw })
    end
  end

  return comment_data
end

M.set_inlines = function()
  vim.fn.setqflist(M.get_quickfix())
  vim.api.nvim_command('Trouble quickfix')
end

M.spawn = function(cmd, opts, input, onexit)
  local handle, pid
  -- open an new pipe for stdout
  local stdout = vim.loop.new_pipe(false)
  -- open an new pipe for stderr
  local stderr = vim.loop.new_pipe(false)
  handle, pid = vim.loop.spawn(cmd, vim.tbl_extend("force", opts, { stdio = { stdout, stderr, } }),
    function(code, signal)
      -- call the exit callback with the code and signal
      onexit(code, signal)
      -- stop reading data to stdout
      vim.loop.read_stop(stdout)
      -- stop reading data to stderr
      vim.loop.read_stop(stderr)
      -- safely shutdown child process
      M.safe_close(handle)
      -- safely shutdown stdout pipe
      M.safe_close(stdout)
      -- safely shutdown stderr pipe
      M.safe_close(stderr)
    end)
  -- read child process output to stdout
  vim.loop.read_start(stdout, input.stdout)
  -- read child process output to stderr
  vim.loop.read_start(stderr, input.stderr)
end

M.safe_close = function(handle)
  if not vim.loop.is_closing(handle) then
    vim.loop.close(handle)
  end
end

return M
