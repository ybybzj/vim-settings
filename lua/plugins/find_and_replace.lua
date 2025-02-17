return {
	{
		"MagicDuck/grug-far.nvim",
		opts = {
			prefills = {
				flags = "-w",
			},
			keymaps = {
				openLocation = { n = "<space>" },
				openNextLocation = { n = "<C-]>" },
				openPrevLocation = { n = "<C-[>" },
				refresh = { n = "<F5>" },
				replace = { n = "<localleader>rr" },
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("my-grug-far-custom-keybinds", { clear = true }),
				pattern = { "grug-far" },
				callback = function()
					vim.keymap.set("n", "<localleader>w", function()
						local state = unpack(require("grug-far").toggle_flags({ "-w" }))
						vim.notify("grug-far: toggled match exact word " .. (state and "ON" or "OFF"))
					end, { buffer = true })

					vim.keymap.set("n", "<localleader>u", function()
						local state = unpack(require("grug-far").toggle_flags({ "--ignore-case" }))
						vim.notify("grug-far: toggled --ignore-case " .. (state and "ON" or "OFF"))
					end, { buffer = true })
				end,
			})
		end,
		keys = {
			{
				"<leader>ff",
				":lua require('config.finder').find_and_replace({ instanceName = \"far\"})<cr>",
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
}
