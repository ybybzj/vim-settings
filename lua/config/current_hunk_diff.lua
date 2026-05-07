local M = {}

local ns = vim.api.nvim_create_namespace("current_hunk_diff")
local group = vim.api.nvim_create_augroup("CurrentHunkDiff", { clear = true })
local state = {}

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
	local normal_fg = get_hl_color("Normal", "fg") or 0xcdd6f4
	local normal_bg = get_hl_color("Normal", "bg") or 0x11111b
	local comment_fg = get_hl_color("Comment", "fg") or 0x6c7086
	local delete_fg = get_hl_color("DiagnosticError", "fg") or 0xf38ba8
	local add_fg = get_hl_color("DiagnosticOk", "fg") or 0xa6e3a1
	local warn_fg = get_hl_color("DiagnosticWarn", "fg") or 0xf9e2af
	local change_fg = warn_fg

	vim.api.nvim_set_hl(0, "CurrentHunkDiffHeader", {
		fg = blend_color(warn_fg, normal_fg, 0.7),
		bg = blend_color(warn_fg, normal_bg, 0.08),
		bold = true,
	})
	vim.api.nvim_set_hl(0, "CurrentHunkDiffBorder", { fg = blend_color(warn_fg, normal_bg, 0.55) })
	vim.api.nvim_set_hl(0, "CurrentHunkDiffContext", { fg = comment_fg })
	vim.api.nvim_set_hl(0, "CurrentHunkDiffDelete", {
		fg = delete_fg,
		bg = blend_color(delete_fg, normal_bg, 0.18),
	})
	vim.api.nvim_set_hl(0, "CurrentHunkDiffAdd", {
		fg = add_fg,
		bg = blend_color(add_fg, normal_bg, 0.16),
	})
	vim.api.nvim_set_hl(0, "CurrentHunkDiffChange", {
		fg = change_fg,
		bg = blend_color(change_fg, normal_bg, 0.16),
	})
	vim.api.nvim_set_hl(0, "CurrentHunkDiffBufAdd", { bg = blend_color(add_fg, normal_bg, 0.1) })
	vim.api.nvim_set_hl(0, "CurrentHunkDiffBufChange", { bg = blend_color(change_fg, normal_bg, 0.1) })
end

set_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
	group = group,
	callback = set_highlights,
})

local function split_ref_text(text)
	local lines = vim.split(text or "", "\n", { plain = true })
	if lines[#lines] == "" then
		table.remove(lines)
	end
	return lines
end

local function hunk_key(hunk)
	return table.concat({ hunk.type, hunk.buf_start, hunk.buf_count, hunk.ref_start, hunk.ref_count }, ":")
end

local function clamp(value, min, max)
	return math.min(math.max(value, min), max)
end

local function hunk_cursor_range(hunk, line_count)
	if hunk.buf_count > 0 then
		return hunk.buf_start, hunk.buf_start + hunk.buf_count - 1
	end

	-- Deleted hunks have no buffer lines. Match mini.diff's own hunk-range
	-- semantics by using max(buf_start, 1) as the cursor target.
	local anchor = clamp(math.max(hunk.buf_start, 1), 1, line_count)
	return anchor, anchor
end

local function find_hunk_at_cursor(data, bufnr)
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	for _, hunk in ipairs(data.hunks or {}) do
		local start_line, end_line = hunk_cursor_range(hunk, line_count)
		if cursor_line >= start_line and cursor_line <= end_line then
			return hunk
		end
	end
end

local function ref_lines_for_hunk(data, hunk)
	if hunk.ref_count == 0 then
		return {}
	end

	local ref_lines = split_ref_text(data.ref_text)
	local lines = {}
	for line = hunk.ref_start, hunk.ref_start + hunk.ref_count - 1 do
		table.insert(lines, ref_lines[line] or "")
	end
	return lines
end

local function overlay_anchor(hunk, bufnr)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if hunk.buf_count == 0 then
		return clamp(math.max(hunk.buf_start, 1), 1, line_count) - 1, true
	end

	return clamp(hunk.buf_start, 1, line_count) - 1, true
end

local function hunk_kind(hunk)
	if hunk.type == "add" then
		return "", "CurrentHunkDiffAdd"
	end
	if hunk.type == "delete" then
		return "", "CurrentHunkDiffDelete"
	end
	return "", "CurrentHunkDiffChange"
end

local function set_hunk_line_highlights(bufnr, hunk)
	if hunk.buf_count == 0 then
		return
	end

	local icon, icon_hl = hunk_kind(hunk)
	local line_hl = hunk.type == "add" and "CurrentHunkDiffBufAdd" or "CurrentHunkDiffBufChange"
	for line = hunk.buf_start, hunk.buf_start + hunk.buf_count - 1 do
		vim.api.nvim_buf_set_extmark(bufnr, ns, line - 1, 0, {
			line_hl_group = line_hl,
			virt_text = { { icon .. " ", icon_hl } },
			virt_text_pos = "inline",
			priority = 198,
		})
	end
end

local function build_virtual_lines(data, hunk)
	local lines = ref_lines_for_hunk(data, hunk)
	local icon, hl = hunk_kind(hunk)
	local virt_lines = {}

	if #lines == 0 then
		return {}
	end

	for _, line in ipairs(lines) do
		table.insert(virt_lines, { { icon .. " ", hl }, { line, hl } })
	end
	return virt_lines
end

local function render_hunk(bufnr, data, hunk)
	set_hunk_line_highlights(bufnr, hunk)

	local line, virt_lines_above = overlay_anchor(hunk, bufnr)
	vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
		virt_lines = build_virtual_lines(data, hunk),
		virt_lines_above = virt_lines_above,
		virt_lines_leftcol = true,
		priority = 198,
	})
end

function M.clear(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
	state[bufnr] = nil
end

function M.show()
	local ok, mini_diff = pcall(require, "mini.diff")
	if not ok then
		vim.notify("mini.diff is not available", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	mini_diff.enable(bufnr)

	local data = mini_diff.get_buf_data(bufnr)
	if not data or not data.ref_text then
		vim.notify("No diff data for current buffer", vim.log.levels.INFO)
		return
	end
	if data.overlay then
		mini_diff.toggle_overlay(bufnr)
	end

	local hunk = find_hunk_at_cursor(data, bufnr)
	if not hunk then
		M.clear(bufnr)
		vim.notify("No diff hunk under cursor", vim.log.levels.INFO)
		return
	end

	M.clear(bufnr)
	render_hunk(bufnr, data, hunk)

	state[bufnr] = { mode = "hunk", key = hunk_key(hunk) }
end

function M.toggle()
	local ok, mini_diff = pcall(require, "mini.diff")
	if not ok then
		vim.notify("mini.diff is not available", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	mini_diff.enable(bufnr)
	local data = mini_diff.get_buf_data(bufnr)
	local hunk = data and find_hunk_at_cursor(data, bufnr)

	if hunk and state[bufnr] and state[bufnr].mode == "hunk" and state[bufnr].key == hunk_key(hunk) then
		M.clear(bufnr)
		return
	end

	M.show()
end

function M.toggle_buffer_overlay()
	local ok, mini_diff = pcall(require, "mini.diff")
	if not ok then
		vim.notify("mini.diff is not available", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	mini_diff.enable(bufnr)

	local data = mini_diff.get_buf_data(bufnr)
	if not data or not data.ref_text or vim.tbl_isempty(data.hunks or {}) then
		M.clear(bufnr)
		vim.notify("No diff hunks for current buffer", vim.log.levels.INFO)
		return
	end
	if data.overlay then
		mini_diff.toggle_overlay(bufnr)
	end
	if state[bufnr] and state[bufnr].mode == "buffer" then
		M.clear(bufnr)
		return
	end

	M.clear(bufnr)
	for _, hunk in ipairs(data.hunks) do
		render_hunk(bufnr, data, hunk)
	end
	state[bufnr] = { mode = "buffer" }
end

function M.toggle_tracking()
	local ok, mini_diff = pcall(require, "mini.diff")
	if not ok then
		vim.notify("mini.diff is not available", vim.log.levels.WARN)
		return
	end

	local bufnr = vim.api.nvim_get_current_buf()
	M.clear(bufnr)
	mini_diff.toggle(bufnr)
end

vim.api.nvim_create_autocmd({ "BufWipeout", "TextChanged", "TextChangedI", "BufWritePost" }, {
	group = group,
	callback = function(event)
		M.clear(event.buf)
	end,
})

vim.api.nvim_create_autocmd("User", {
	group = group,
	pattern = "MiniDiffUpdated",
	callback = function(event)
		local bufnr = event.buf ~= 0 and event.buf or event.data and event.data.buf
		if bufnr then
			M.clear(bufnr)
		end
	end,
})

return M
