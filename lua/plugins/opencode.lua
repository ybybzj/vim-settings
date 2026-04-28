-- opencode.nvim: Deep integration with opencode CLI
-- Handles: prompts, context injection, session management, permissions, buffer reload
return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	config = function()
		local opencode_cmd = "opencode --port"
		local function opencode_root()
			local ok, workspace = pcall(require, "workspace")
			if ok and workspace.is_open() then
				return workspace.active_dir()
			end
			return vim.fn.getcwd(-1, -1)
		end

		local function terminal_opts(cwd)
			cwd = cwd or opencode_root()
			return {
				auto_close = false,
				cwd = cwd,
				win = {
					position = "right",
					enter = false,
					on_win = function(win)
						require("opencode.terminal").setup(win.win)
					end,
				},
			}
		end

		local function stop_for_root(cwd)
			local terminal = require("snacks.terminal").get(opencode_cmd, vim.tbl_extend("force", terminal_opts(cwd), {
				create = false,
			}))
			if terminal then
				terminal:close()
			end
		end

		---@type opencode.Opts
		vim.g.opencode_opts = {
			server = {
				start = function()
					require("snacks.terminal").open(opencode_cmd, terminal_opts())
				end,
				stop = function()
					stop_for_root(opencode_root())
				end,
				toggle = function()
					require("snacks.terminal").toggle(opencode_cmd, terminal_opts())
				end,
			},
		}

		vim.api.nvim_create_autocmd("User", {
			pattern = "WorkspaceRootChanged",
			callback = function(event)
				local data = event.data or {}
				if data.previous_root and data.previous_root ~= data.active_root then
					stop_for_root(data.previous_root)
				end
			end,
		})

		-- Required for auto-reload when opencode edits files
		vim.o.autoread = true

		local opencode = require("opencode")
		local function code_diff(cmd)
			vim.cmd(cmd)
		end

		-- CLI toggles (matching your <space>a* prefix)
		vim.keymap.set("n", "<space>ai", function()
			opencode.toggle()
		end, { desc = "Toggle OpenCode CLI" })

		vim.keymap.set("n", "<space>as", function()
			opencode.select()
		end, { desc = "Select CLI Tool" })

		vim.keymap.set({ "n", "x" }, "<space>ap", function()
			opencode.select()
		end, { desc = "Select Prompt" })

		-- Prompts (matching your previous keybindings)
		vim.keymap.set({ "n", "x" }, "<space>ae", function()
			opencode.ask("Explain @this", { submit = true })
		end, { desc = "Explain" })

		vim.keymap.set({ "n", "x" }, "<space>ao", function()
			opencode.ask("How can @this be optimized?", { submit = true })
		end, { desc = "Optimize" })

		vim.keymap.set({ "n", "x" }, "<space>at", function()
			opencode.ask("Can you write tests for @this?", { submit = true })
		end, { desc = "Tests" })

		vim.keymap.set({ "n", "x" }, "<space>ad", function()
			opencode.ask("Add documentation to @this", { submit = true })
		end, { desc = "Document" })

		vim.keymap.set({ "n", "x" }, "<space>af", function()
			opencode.ask("Can you fix @this?", { submit = true })
		end, { desc = "Fix" })

		-- Additional useful bindings (matching your setup)
		vim.keymap.set("n", "<space>aF", function()
			opencode.ask("@buffer", { submit = true })
		end, { desc = "Send File" })

		vim.keymap.set("x", "<space>av", function()
			opencode.ask("@this", { submit = true })
		end, { desc = "Send Selection" })

		vim.keymap.set("x", "<space>al", function()
			opencode.ask("@this", { submit = true })
		end, { desc = "Send Selection" })

		vim.keymap.set("n", "<space>aD", function()
			opencode.command("session.interrupt")
		end, { desc = "Interrupt Session" })

		-- Review workflow for opencode edits
		vim.keymap.set("n", "<space>aw", function()
			code_diff("CodeDiff")
		end, { desc = "Review Workspace Diff" })
		vim.keymap.set("n", "<space>arw", function()
			code_diff("CodeDiff")
		end, { desc = "Review Workspace Diff" })

		vim.keymap.set("n", "<space>aH", function()
			code_diff("CodeDiff file HEAD")
		end, { desc = "Review File vs HEAD" })
		vim.keymap.set("n", "<space>arh", function()
			code_diff("CodeDiff file HEAD")
		end, { desc = "Review File vs HEAD" })

		vim.keymap.set("n", "<space>aj", function()
			require("gitsigns").next_hunk()
		end, { desc = "Next Hunk" })
		vim.keymap.set("n", "<space>arj", function()
			require("gitsigns").next_hunk()
		end, { desc = "Next Hunk" })

		vim.keymap.set("n", "<space>ak", function()
			require("gitsigns").prev_hunk()
		end, { desc = "Prev Hunk" })
		vim.keymap.set("n", "<space>ark", function()
			require("gitsigns").prev_hunk()
		end, { desc = "Prev Hunk" })

		vim.keymap.set("n", "<space>aP", function()
			require("gitsigns").preview_hunk()
		end, { desc = "Preview Hunk" })
		vim.keymap.set("n", "<space>arp", function()
			require("gitsigns").preview_hunk()
		end, { desc = "Preview Hunk" })

		vim.keymap.set("n", "<space>aq", function()
			vim.cmd("tabclose")
		end, { desc = "Close Diff Review" })
		vim.keymap.set("n", "<space>arq", function()
			vim.cmd("tabclose")
		end, { desc = "Close Diff Review" })

		vim.api.nvim_create_user_command("OpenCodeReview", function()
			code_diff("CodeDiff")
		end, { desc = "Open workspace diff review for opencode edits" })

		vim.api.nvim_create_user_command("OpenCodeReviewFile", function()
			code_diff("CodeDiff file HEAD")
		end, { desc = "Open current file diff review against HEAD" })

		-- Operator for ranges (vim-native feel, bonus feature)
		vim.keymap.set({ "n", "x" }, "go", function()
			return opencode.operator("@this ")
		end, { expr = true, desc = "Add range to opencode" })

		vim.keymap.set("n", "goo", function()
			return opencode.operator("@this ") .. "_"
		end, { expr = true, desc = "Add line to opencode" })

		-- Session management (new features from opencode.nvim)
		vim.keymap.set("n", "<space>an", function()
			opencode.command("session.new")
		end, { desc = "New session" })

		vim.keymap.set("n", "<space>aL", function()
			opencode.command("session.list")
		end, { desc = "List sessions" })

		vim.keymap.set("n", "<space>ac", function()
			opencode.command("session.compact")
		end, { desc = "Compact session" })

		vim.keymap.set("n", "<space>au", function()
			opencode.command("session.undo")
		end, { desc = "Undo" })

		vim.keymap.set("n", "<space>ar", function()
			opencode.command("session.redo")
		end, { desc = "Redo" })
	end,
}
