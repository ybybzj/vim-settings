return {
	server_name = "marksman",
	dependencies = {
		{
			"bullets-vim/bullets.vim",
			config = function()
				vim.g.bullets_enabled_file_types = { "markdown" }
			end,
		},
	},
	opts = {},
	formatter = {
		markdown = { "prettierd", "prettier" },
	},
}
