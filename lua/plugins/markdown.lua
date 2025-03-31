return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		opts = {},
		keys = {
			{ "<space>mr", "<cmd>:RenderMarkdown buf_toggle<cr>", desc = "Toggle Markdown Render" },
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_filetypes = { "markdown", "copilot-chat" }
		end,

		keys = {
			{ "<space>mp", "<cmd>MarkdownPreview<CR>", desc = "Markdown Preview" },
			{ "<space>mt", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Preview Toggle" },
			{ "<space>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Preview Stop" },
		},
	},
}
