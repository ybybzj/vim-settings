-- TypeScript/JavaScript language server backend switch:
--   true  -> native TypeScript 7 (tsgo), vtsls only as a per-workspace fallback
--   false -> previous behaviour (vtsls only)
-- See docs/typescript-lsp-tsgo.md.
local tsgo = require("lsp.utils.tsgo")
local USE_TSGO = true
local TS_FILETYPES = { "javascript", "javascriptreact", "typescript", "typescriptreact" }

-- Workspace root for TS buffers: the git worktree first, so one server serves
-- every package (what working from the repo root needs), then the nearest
-- project marker, then the file's own directory for loose scripts.
local function workspace_root(bufnr)
	return vim.fs.root(bufnr, { ".git" })
		or vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json", "package.json" })
		or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
end

return {
	server_name = "vtsls",
	debugger_name = "js-debug-adapter",
	tools = { "prettierd", "eslint_d" },
	dependencies = {
		{
			"dmmulroy/tsc.nvim",
			opts = {},
		},
		{
			"mfussenegger/nvim-lint",
		},
		{
			"yioneko/nvim-vtsls",
		},
	},
	formatter = {
		javascript = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
	},
	linter = {
		javascript = { "eslint_d" },
		typescript = { "eslint_d" },
	},
	opts = {
		settings = {
			javascript = {
				preferences = {
					importModuleSpecifier = "relative",
				},
			},
			typescript = {
				preferences = {
					importModuleSpecifier = "relative",
				},
				inlayHints = {
					parameterNames = { enabled = "literals" },
					parameterTypes = { enabled = true },
					variableTypes = { enabled = false },
					propertyDeclarationTypes = { enabled = true },
					functionLikeReturnTypes = { enabled = true },
					enumMemberValues = { enabled = true },
				},
			},
		},
	},
	lspconfig = function(_, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			-- no default maps, so you may want to define some here

			old_on_attach(client, bufnr)
		end

		-- Setup nvim-vtsls plugin (provides helper commands)
		local vtsls = require("vtsls")
		vtsls.config({
			refactor_auto_rename = true,
		})

		-- Define server config using new API
		-- mason-lspconfig will automatically call vim.lsp.enable('vtsls')
		if USE_TSGO then
			-- Exactly one backend activates per buffer: both gate through
			-- root_dir/on_dir (returning without calling on_dir skips the
			-- client), so tsgo claims workspaces that ship native TS 7 while
			-- vtsls only takes over workspaces that do not.
			vim.lsp.config("tsgo", {
				filetypes = TS_FILETYPES,
				capabilities = opts.capabilities,
				on_attach = opts.on_attach,
				settings = opts.settings,
				cmd = function(dispatchers, config)
					local exe = tsgo.command(config.root_dir)
					if not exe then
						error("tsgo: no native TypeScript 7 found for " .. tostring(config.root_dir))
					end
					local cmd = vim.list_extend({}, exe)
					vim.list_extend(cmd, { "--lsp", "-stdio" })
					return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.root_dir })
				end,
				root_dir = function(bufnr, on_dir)
					local root = workspace_root(bufnr)
					if root and tsgo.command(root) then
						on_dir(root)
					end
				end,
			})
			vim.lsp.enable("tsgo")

			opts.root_dir = function(bufnr, on_dir)
				local root = workspace_root(bufnr)
				if root and not tsgo.command(root) then
					on_dir(root)
				end
			end
		end
		vim.lsp.config('vtsls', opts)

	end,
	keys = {
		-- VtsExec needs a vtsls client, so route these through a guard that
		-- degrades to a warning when tsgo owns the workspace.
		["<space>oi"] = {
			cmd = "<cmd>lua require('lsp.utils.tsgo').vts_exec('organize_imports')<CR>",
		},
		["<space>rf"] = {
			cmd = "<cmd>lua require('lsp.utils.tsgo').vts_exec('rename_file')<CR>",
		},
		["<space>st"] = {
			cmd = "<cmd>lua require('lsp.utils.tsgo').vts_exec('select_ts_version')<CR>",
		},
		["<space>fr"] = {
			cmd = "<cmd>lua require('lsp.utils.tsgo').vts_exec('file_references')<CR>",
		},
	},
}
