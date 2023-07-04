local config = require('phab.config')
-- local commands = require('focus.modules.commands')
-- local autocmd = require('focus.modules.autocmd')
-- local split = require('focus.modules.split')
-- local functions = require('focus.modules.functions')
-- local resizer = require('focus.modules.resizer')

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
  --
  -- -- Don't set up focus if its not enabled by the user
  if M.enable then
    -- Focus is enabled when setup is run, we use this var to enable/disable/toggle
    vim.g.enabled_focus_resizing = 1
  end
end

M.set_inlines = function()
  local output = vim.fn.system { 'echo', 'hi' }
  -- local bufnr = vim.api.nvim_get_current_buf()
  -- local lines = {}
  -- for i = 1, 3 do
  --   table.insert(lines, ('%d | %s'):format(i, vim.fn.strftime('%F')))
  -- end
  -- -- vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  -- vim.fn.setqflist({
  --   { bufnr = bufnr, lnum = 1, col = 5 , text = "foo"}, 
  --   { bufnr = bufnr, lnum = 2, col = 10 , text = "bar"},
  --   { bufnr = bufnr, lnum = 3, col = 13 , text = "baz" }
  -- })
  --
  -- vim.api.nvim_command('Trouble quickfix')
end
--
-- M.resize = function()
-- 	resizer.split_resizer(M)
-- end
--
-- -- Exported internal functions for use in commands
-- function M.split_nicely(args)
-- 	split.split_nicely(args, M.bufnew)
-- end
--
-- function M.split_command(direction, args)
-- 	args = args or ''
-- 	split.split_command(direction, args, M.tmux, M.bufnew)
-- end
--
-- function M.split_cycle(reverse)
-- 	split.split_cycle(reverse, M.bufnew)
-- end
--
-- function M.focus_enable()
-- 	functions.focus_enable()
-- end
--
-- function M.focus_disable()
-- 	functions.focus_disable()
-- end
--
-- function M.focus_toggle()
-- 	functions.focus_toggle()
-- end
--
-- function M.focus_maximise()
-- 	functions.focus_maximise()
-- end
--
-- function M.focus_equalise()
-- 	functions.focus_equalise()
-- end
--
-- function M.focus_max_or_equal()
-- 	functions.focus_max_or_equal()
-- end
--
-- function M.focus_disable_window()
-- 	table.insert(M.excluded_windows, vim.api.nvim_get_current_win())
-- end
--
-- function M.focus_enable_window()
-- 	for k, v in pairs(M.excluded_windows) do
-- 		if v == vim.api.nvim_get_current_win() then
-- 			table.remove(M.excluded_windows, k)
-- 		end
-- 	end
-- end
--
-- function M.focus_toggle_window()
-- 	for _, v in pairs(M.excluded_windows) do
-- 		if v == vim.api.nvim_get_current_win() then
-- 			M.focus_enable_window()
-- 			return
-- 		end
-- 	end
-- 	M.focus_disable_window()
-- end
--
-- function M.focus_get_disabled_windows()
-- 	print('------------------')
-- 	print('█▀ ▄▀▄ ▄▀▀ █ █ ▄▀▀')
-- 	print('█▀ ▀▄▀ ▀▄▄ ▀▄█ ▄██')
-- 	print('------------------')
-- 	print('Disabled Windows')
-- 	for _, v in pairs(M.excluded_windows) do
-- 		print('- ' .. v)
-- 	end
-- 	print('-------------------')
-- 	print('Current Window')
-- 	print('- ' .. vim.api.nvim_get_current_win())
-- 	print('-------------------')
-- end

return M
