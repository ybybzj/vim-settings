-- opencode.nvim: Deep integration with opencode CLI
-- Handles: prompts, context injection, session management, permissions, buffer reload
return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		"folke/snacks.nvim",
	},
	config = function()
		---@type opencode.Opts
		vim.g.opencode_opts = {
			provider = {
				enabled = "snacks",
				snacks = {
					auto_close = false, -- Keep terminal alive when hidden to persist session
				},
			},
		}

		-- Required for auto-reload when opencode edits files
		vim.o.autoread = true

		local opencode = require("opencode")

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
