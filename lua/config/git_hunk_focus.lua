local M = {}

local ns = vim.api.nvim_create_namespace("git_hunk_focus")
local group = vim.api.nvim_create_augroup("GitHunkFocus", { clear = true })
local refresh_timers = {}
local enabled_var = "git_hunk_focus_enabled"

local function get_hl_color(name, key)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	return ok and hl[key]
end

local function blend_color(fg, bg, alpha)
	local function channel(color, shift)
		return math.floor(color / 2 ^ shift) % 256
	end

	local r = math.floor(channel(fg, 16) * alpha + channel(bg, 16) * (1 - alpha))
	local g = math.floor(channel(fg, 8) * alpha + channel(bg, 8) * (1 - alpha))
	local b = math.floor(channel(fg, 0) * alpha + channel(bg, 0) * (1 - alpha))
	return r * 65536 + g * 256 + b
end

local function set_highlights()
	local bg = get_hl_color("Normal", "bg") or 0x181616
	local normal_fg = get_hl_color("Normal", "fg") or 0xc5c9c5
	local comment_fg = get_hl_color("Comment", "fg") or normal_fg

	-- Use theme-derived colors instead of a static link so focused hunks stand out
	-- consistently after colorscheme changes. The minimap dim is intentionally
	-- darker than buffer dim because map glyphs are tiny and need stronger contrast.
	vim.api.nvim_set_hl(0, "GitHunkFocusDim", { fg = blend_color(normal_fg, bg, 0.42) })
	vim.api.nvim_set_hl(0, "GitHunkFocusMapDim", { fg = blend_color(comment_fg, bg, 0.24) })
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = set_highlights,
})

local function refresh_minimap()
	if not package.loaded["mini.map"] then
		return
	end

	local ok, minimap = pcall(require, "mini.map")
	if ok and minimap.current and minimap.current.buf_data then
		minimap.refresh({}, { lines = false, scrollbar = false })
	end
end

local function clear_timer(bufnr)
	local timer = refresh_timers[bufnr]
	if timer then
		timer:stop()
		timer:close()
		refresh_timers[bufnr] = nil
	end
end

local function set_enabled(enabled)
	vim.g[enabled_var] = enabled or nil
end

local function is_enabled()
	return vim.g[enabled_var] == true
end

local function set_ranges(bufnr, ranges)
	vim.b[bufnr].git_hunk_focus_ranges = ranges
end

local function clear_hunk_focus(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if vim.api.nvim_buf_is_valid(bufnr) then
		vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
		set_ranges(bufnr, nil)
	end
	refresh_minimap()
end

local function for_each_loaded_buffer(callback)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) then
			callback(buf)
		end
	end
end

local function clear_all_buffers()
	for_each_loaded_buffer(function(bufnr)
		clear_timer(bufnr)
		clear_hunk_focus(bufnr)
	end)
end

local function clamp_hunk_range(hunk, line_count)
	if not hunk.added or line_count == 0 then
		return nil
	end

	local start = hunk.added.start
	local count = hunk.added.count

	-- Pure deletion hunks have no added lines. Keep the sign line visible so the
	-- deletion still stands out while unchanged context is dimmed.
	if count == 0 then
		start = math.min(math.max(start, 1), line_count)
		count = 1
	end

	local finish = math.min(start + count - 1, line_count)
	start = math.max(start, 1)
	if finish < start then
		return nil
	end

	return { start = start, finish = finish, type = hunk.type }
end

local function collect_hunk_ranges(bufnr)
	local ok, gitsigns = pcall(require, "gitsigns")
	if not ok then
		return {}
	end

	local hunks = gitsigns.get_hunks(bufnr) or {}
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local ranges = {}

	for _, hunk in ipairs(hunks) do
		local range = clamp_hunk_range(hunk, line_count)
		if range then
			ranges[#ranges + 1] = range
		end
	end

	table.sort(ranges, function(left, right)
		return left.start < right.start
	end)

	return ranges
end

local function merge_ranges(ranges)
	local merged = {}
	for _, range in ipairs(ranges) do
		local last = merged[#merged]
		if last and range.start <= last.finish + 1 then
			last.finish = math.max(last.finish, range.finish)
		else
			merged[#merged + 1] = { start = range.start, finish = range.finish }
		end
	end
	return merged
end

local function dim_range(bufnr, start_line, finish_line)
	if start_line > finish_line then
		return
	end

	vim.api.nvim_buf_set_extmark(bufnr, ns, start_line - 1, 0, {
		end_row = finish_line,
		end_col = 0,
		hl_group = "GitHunkFocusDim",
		hl_eol = true,
		priority = 200,
		strict = false,
	})
end

function M.apply(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	local ranges = collect_hunk_ranges(bufnr)
	if #ranges == 0 then
		set_ranges(bufnr, nil)
		refresh_minimap()
		return false
	end

	set_ranges(bufnr, ranges)

	-- Dim unchanged ranges in batches instead of placing one extmark per line.
	-- Hunk ranges remain untouched, so git changes stay visually prominent.
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local next_dim_start = 1
	for _, range in ipairs(merge_ranges(ranges)) do
		dim_range(bufnr, next_dim_start, range.start - 1)
		next_dim_start = math.max(next_dim_start, range.finish + 1)
	end
	dim_range(bufnr, next_dim_start, line_count)

	refresh_minimap()
	return true
end

function M.refresh(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) or not is_enabled() then
		return
	end

	if not M.apply(bufnr) then
		clear_hunk_focus(bufnr)
	end
end

function M.schedule_refresh(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) or not is_enabled() then
		return
	end

	clear_timer(bufnr)
	local timer = vim.uv.new_timer()
	refresh_timers[bufnr] = timer
	timer:start(250, 0, vim.schedule_wrap(function()
		clear_timer(bufnr)
		M.refresh(bufnr)
	end))
end

function M.toggle()
	if is_enabled() then
		set_enabled(false)
		clear_all_buffers()
		vim.notify("Git hunk focus disabled", vim.log.levels.INFO)
		return
	end

	set_enabled(true)
	for_each_loaded_buffer(M.refresh)
	vim.notify("Git hunk focus enabled", vim.log.levels.INFO)
end

function M.minimap_integration()
	return function()
		local ok, minimap = pcall(require, "mini.map")
		if not ok or not minimap.current or not minimap.current.buf_data then
			return {}
		end

		local bufnr = minimap.current.buf_data.source
		if not bufnr and vim.api.nvim_get_current_buf() ~= minimap.current.buf_data.map then
			bufnr = vim.api.nvim_get_current_buf()
		end
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) or not is_enabled() then
			return {}
		end

		local line_count = vim.api.nvim_buf_line_count(bufnr)
		local ranges = vim.b[bufnr].git_hunk_focus_ranges or {}
		if #ranges == 0 then
			return {}
		end

		local result = {}
		local hunk_rows = {}
		local hunk_highlights = {
			add = "GitSignsAdd",
			change = "GitSignsChange",
			delete = "GitSignsDelete",
		}

		-- Return hunk rows first so compressed minimap rows prefer git colors over
		-- dimmed context when both land on the same map line.
		for _, range in ipairs(ranges) do
			local hl_group = hunk_highlights[range.type] or "GitSignsChange"
			for line = range.start, range.finish do
				hunk_rows[line] = true
				result[#result + 1] = { line = line, hl_group = hl_group }
			end
		end

		for line = 1, line_count do
			if not hunk_rows[line] then
				result[#result + 1] = { line = line, hl_group = "GitHunkFocusMapDim" }
			end
		end

		return result
	end
end

vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "GitSignsUpdate",
	callback = function(args)
		local bufnr = args.data and args.data.buffer
		if bufnr then
			M.refresh(bufnr)
		else
			for_each_loaded_buffer(M.refresh)
		end
	end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "TextChanged", "TextChangedI", "BufWritePost" }, {
	group = group,
	callback = function(args)
		M.schedule_refresh(args.buf)
	end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
	group = group,
	callback = function(args)
		clear_timer(args.buf)
		if vim.api.nvim_buf_is_valid(args.buf) then
			set_ranges(args.buf, nil)
		end
	end,
})

return M
