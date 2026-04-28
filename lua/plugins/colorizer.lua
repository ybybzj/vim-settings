return {
	{
		"NvChad/nvim-colorizer.lua",
		enabled = true,
		event = { "BufReadPre", "BufNewFile" },
		cmd = { "ColorizerAttachToBuffer", "ColorizerDetachFromBuffer", "ColorizerReloadAllBuffers", "ColorizerToggle" },
		config = function()
			require("colorizer").setup()
		end,
	},
}
