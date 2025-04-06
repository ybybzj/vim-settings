return {
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				ignore_filetypes = { "zig", "ocaml", "rescript" },
			})
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					ocaml = true,
					-- lua = true,
					-- javascript = true,
					-- typescript = true,
					zig = true,
					rescript = true,
					["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
				},
			})
		end,
	},
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		lazy = false,
		build = "make tiktoken", -- Only on MacOS or Linux
		opts = function()
			return {
				model = "claude-3.7-sonnet-thought",
				-- See Configuration section for options
				providers = {
					copilot = {},
					github_models = {},
					copilot_embeddings = {},
					ollama = {
						prepare_input = require("CopilotChat.config.providers").copilot.prepare_input,
						prepare_output = require("CopilotChat.config.providers").copilot.prepare_output,

						get_models = function(headers)
							local response, err =
								require("CopilotChat.utils").curl_get("http://192.168.50.117:5001/v1/models", {
									headers = headers,
									json_response = true,
								})

							if err then
								error(err)
							end

							return vim.tbl_map(function(model)
								return {
									id = model.id,
									name = model.id,
								}
							end, response.body.data)
						end,

						embed = function(inputs, headers)
							local response, err =
								require("CopilotChat.utils").curl_post("http://192.168.50.117:5001/v1/embeddings", {
									headers = headers,
									json_request = true,
									json_response = true,
									body = {
										input = inputs,
										model = "all-minilm",
									},
								})

							if err then
								error(err)
							end

							return response.body.data
						end,

						get_url = function()
							return "http://192.168.50.117:5001/v1/chat/completions"
						end,
					},
				},
			}
		end,
		keys = {
			{ "<space>ai", "<cmd>CopilotChatToggle<cr>", desc = "Toogle Copilot Chat" },
			{ "<space>ae", "<cmd>CopilotChatExplain<cr>", desc = "Explain Code" },
			{ "<space>ao", "<cmd>CopilotChatOptimize<cr>", desc = "Optimize Code" },
			{ "<space>at", "<cmd>CopilotChatTests<cr>", desc = "Generate tests for Code" },
			{ "<space>ad", "<cmd>CopilotChatDocs<cr>", desc = "Generate documentation comments for Code" },
			{ "<space>af", "<cmd>CopilotChatFix<cr>", desc = "Rewrite Code with bug fixes" },
		},
	},
}
