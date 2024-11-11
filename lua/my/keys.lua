local map = require("my.shared").mapkey
local cmd = vim.cmd

------------------key mappings -----------------------
map("", "<leader>l", ":Neotree toggle reveal=true<cr>")
map("", "<leader>gf", ":Neotree reveal=true<cr>")
map("", "<leader>q", ":copen<cr>")
map("", "<leader>cd", ":cd %:p:h<cr>")
cmd([[
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
]])

map("n", "<M-s>", "<Esc>:wa<cr><Esc>")
map("i", "<M-s>", "<Esc>:wa<cr>")
map("", "<M-q>", "<Esc>:q<cr>")
map("", "<M-Q>", "<Esc>:qa<cr>")
map("", "<leader>ct", "<Esc>:tabclose<cr>")
map("", "<leader>vr", ":Reload<cr>")
map("n", "<leader>ve", ":e ~/.config/nvim/<cr>")
map("n", "<leader>te", ":e ~/.config/tmux/tmux.conf<cr>")
map("n", "<cr>", ":noh<cr><cr>")
map("n", "<Up>", "gk")
map("n", "<Down>", "gj")
------- copy --------------
map("v", "<M-c>", '"+y<cr>')
map("n", "<M-v>", '"+P<cr>')
map("v", "<M-v>", '"+P<cr>')

-------zen mode -----------
map("n", "<leader>zm", ":ZenMode<cr>")
map("n", "<leader>tw", ":Twilight<cr>")

-- smooth scroll --

-- hopper setting --
map("n", "$", ":HopWord<cr>")
map("n", "<leader>hL", ":HopLine<cr>")
map("n", "<leader>hl", ":HopChar1<cr>")
-- minimap --
map("n", "<leader>m", "<cmd>lua MiniMap.toggle()<cr>")

-- lazygit --
map("n", "<leader>gg", "<cmd>lua _git_toggle()<CR>", { silent = true })

-- clear notifications --
map("n", "<leader>cc", "<cmd>lua require('notify').dismiss()<CR>", { silent = true })

-- clear floating popups --
vim.api.nvim_create_user_command("CloseFloatingWindows", function(opts)
	for _, window_id in ipairs(vim.api.nvim_list_wins()) do
		-- If window is floating
		if vim.api.nvim_win_get_config(window_id).relative ~= "" then
			-- Force close if called with !
			vim.api.nvim_win_close(window_id, opts.bang)
		end
	end
end, { bang = true, nargs = 0 })
