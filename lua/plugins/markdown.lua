return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		lazy = true,
		cmd = "RenderMarkdown",
		ft = { "markdown", "copilot-chat" },
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
		opts = {
			-- Keep markdown buffers plain by default; render only when toggled.
			enabled = false,
			completions = {
				lsp = { enabled = true },
				blink = { enabled = true },
			},
		},
		keys = {
			{ "<space>mr", "<cmd>:RenderMarkdown buf_toggle<cr>", desc = "Toggle Markdown Render" },
		},
	},
	{
		"iamcco/markdown-preview.nvim",
		lazy = true,
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown", "copilot-chat" },
		build = "cd app && yarn install",
		init = function()
			vim.g.mkdp_auto_start = 0
			vim.g.mkdp_filetypes = { "markdown", "copilot-chat" }
		end,

		keys = {
			{ "<space>mp", "<cmd>MarkdownPreviewToggle<CR>", desc = "Markdown Preview Toggle" },
			{ "<space>ms", "<cmd>MarkdownPreviewStop<CR>", desc = "Markdown Preview Stop" },
		},
	},
}
