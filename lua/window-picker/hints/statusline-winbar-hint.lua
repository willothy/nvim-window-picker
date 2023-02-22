local StatuslineHint = require('window-picker.hints.statusline-hint')

---@class StatuslineWinbarHint
---@field window_options table<string, any> window options
---@field global_options table<string, any> global options
---@field chars string[] list of chars to hint
---@field selection_display function function to customize the hint
local M = StatuslineHint:new()

function M:set_config(config)
	self.chars = config.chars
	self.selection_display = config.selection_display
	self.use_winbar = config.use_winbar
	self.show_prompt = config.show_prompt

	vim.api.nvim_set_hl(0, 'WindowPickerStatusLine', {
		fg = '#ededed',
		bg = config.current_win_hl_color,
		bold = true,
	})

	vim.api.nvim_set_hl(0, 'WindowPickerStatusLineNC', {
		fg = '#ededed',
		bg = config.other_win_hl_color,
		bold = true,
	})

	vim.api.nvim_set_hl(0, 'WindowPickerWinBar', {
		fg = '#ededed',
		bg = config.current_win_hl_color,
		bold = true,
	})

	vim.api.nvim_set_hl(0, 'WindowPickerWinBarNC', {
		fg = '#ededed',
		bg = config.other_win_hl_color,
		bold = true,
	})
end

--- Shows the characters in status line
--- @param windows number[] windows to draw the hints on
function M:draw(windows)
	local use_winbar = false

	-- calculate if we should use winbar or not
	if self.use_winbar == 'always' then
		use_winbar = true
	elseif self.use_winbar == 'never' then
		use_winbar = false
	elseif self.use_winbar == 'smart' then
		use_winbar = vim.o.cmdheight == 0
	end

	local indicator_setting = use_winbar and 'winbar' or 'statusline'
	local indicator_hl = use_winbar and 'WinBar' or 'StatusLine'

	if not use_winbar then
		if vim.o.laststatus ~= 2 then
			self.global_options['laststatus'] = vim.o['laststatus']
			vim.o.laststatus = 2
		end

		if self.show_prompt and vim.o.cmdheight < 1 then
			self.global_options['cmdheight'] = vim.o['cmdheight']
			vim.o.cmdheight = 1
		end
	end

	local win_opt_to_cap = { indicator_setting, 'winhl' }
	self:save_window_options(windows, win_opt_to_cap)

	for index, window in ipairs(windows) do
		local char = self.chars[index]

		vim.wo[window][indicator_setting] = self.selection_display
				and self.selection_display(char, window)
			or '%=' .. char .. '%='

		vim.wo[window].winhl = string.format(
			'%s:WindowPicker%s,%sNC:WindowPicker%sNC',
			indicator_hl,
			indicator_hl,
			indicator_hl,
			indicator_hl
		)
	end

	vim.cmd.redraw()
end

return M
