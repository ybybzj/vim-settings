local cmd = vim.cmd
local status_ok, bqf = pcall(require, "bqf")
if not status_ok then
	return
end

cmd([[
    hi BqfPreviewBorder guifg=#50a14f ctermfg=71
    hi link BqfPreviewRange Search
]])

bqf.setup({
	auto_enable = true,
	auto_resize_height = true, -- highly recommended enable
	preview = {
		win_height = 12,
		win_vheight = 12,
		delay_syntax = 80,
		border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
		should_preview_cb = function(bufnr, qwinid)
			local ret = true
			local bufname = vim.api.nvim_buf_get_name(bufnr)
			local fsize = vim.fn.getfsize(bufname)
			if fsize > 100 * 1024 then
				-- skip file size greater than 100k
				ret = false
			elseif bufname:match("^fugitive://") then
				-- skip fugitive buffer
				ret = false
			end
			return ret
		end,
	},
	-- make `drop` and `tab drop` to become preferred
	func_map = {
		drop = "o",
		openc = "O",
		split = "<C-s>",
		tabdrop = "<C-t>",
		tabc = "",
		ptogglemode = "z,",
		del = "<C-x>",
	},
	filter = {
		fzf = {
			action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
			extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
		},
	},
})
