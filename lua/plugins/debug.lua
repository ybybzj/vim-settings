return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		dependencies = {
			"williamboman/mason.nvim",
			{
				"theHamsta/nvim-dap-virtual-text",
				dependencies = {
					"nvim-treesitter/nvim-treesitter",
				},
				opts = {},
			},
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				config = function()
					local dapui = require("dapui")
					dapui.setup({
						icons = { expanded = "▾", collapsed = "▸", current_frame = "*" },
						controls = {
							icons = {
								pause = "⏸",
								play = "▶",
								step_into = "⏎",
								step_over = "⏭",
								step_out = "⏮",
								step_back = "b",
								run_last = "▶▶",
								terminate = "⏹",
								disconnect = "⏏",
							},
						},
					})

					local dap = require("dap")
					dap.listeners.after.event_initialized["dapui_config"] = dapui.open
					dap.listeners.before.event_terminated["dapui_config"] = dapui.close
					dap.listeners.before.event_exited["dapui_config"] = dapui.close
				end,
			},
		},
		config = function()
			local dap = require("dap")
			local utils = require("dap.utils")
			if not dap.adapters["pwa-node"] then
				dap.adapters["pwa-node"] = {
					type = "server",
					host = "localhost",
					port = "${port}",
					executable = {
						command = "js-debug-adapter",
						-- 💀 Make sure to update this path to point to your installation
						args = {
							"${port}",
						},
					},
				}
			end
			if not dap.adapters["node"] then
				dap.adapters["node"] = function(cb, config)
					if config.type == "node" then
						config.type = "pwa-node"
					end
					local nativeAdapter = dap.adapters["pwa-node"]
					if type(nativeAdapter) == "function" then
						nativeAdapter(cb, config)
					else
						cb(nativeAdapter)
					end
				end
			end

			local js_filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

			local vscode = require("dap.ext.vscode")
			vscode.type_to_filetypes["node"] = js_filetypes
			vscode.type_to_filetypes["pwa-node"] = js_filetypes

			for _, language in ipairs(js_filetypes) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch file",
						program = "${file}",
						cwd = "${workspaceFolder}",
					},
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = utils.pick_process,
						cwd = "${workspaceFolder}",
					},
					{
						name = "tsx (" .. "current_file" .. ")",
						type = "node",
						request = "launch",
						program = "${file}",
						runtimeExecutable = "tsx",
						cwd = "${workspaceFolder}",
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
					},
					{
						name = "Debug Current Jest File",
						type = "node",
						request = "launch",
						cwd = "${workspaceFolder}",
						program = "${workspaceFolder}/node_modules/jest/bin/jest",
						args = {
							"${fileBasename}",
							"--runInBand",
							"--no-cache",
						},
						console = "integratedTerminal",
						internalConsoleOptions = "neverOpen",
						sourceMaps = true,
					},
				}
			end
		end,
		keys = {
			{ "<leader>dc", "<cmd>lua require('dap').continue()<cr>", desc = "Continue" },
			{ "<F10>", "<cmd>lua require('dap').step_over()<cr>", desc = "Step Over" },
			{ "<F11>", "<cmd>lua require('dap').step_into()<cr>", desc = "Step Into" },
			{ "<F12>", "<cmd>lua require('dap').step_out()<cr>", desc = "Step Out" },
			{ "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
			{ "<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", desc = "Open Repl" },
			{ "<leader>dt", "<cmd>lua require('dap').terminate()<cr>", desc = "Terminate" },
		},
	},
}
