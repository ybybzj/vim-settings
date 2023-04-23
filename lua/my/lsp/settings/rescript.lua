local handlers = require("my.lsp.handlers")

return {
	-- Using mason.nvim plugin
	cmd = { "rescript-lsp", "--stdio" },
	on_attach = function(client, bufnr)
		-- client.server_capabilities.semanticTokensProvider = false
		handlers.lsp_keymaps(client, bufnr)
	end,
	commands = {
		ResOpenCompiled = {
			require("rescript-tools").open_compiled,
			description = "Open Compiled JS",
		},
		ResCreateInterface = {
			require("rescript-tools").create_interface,
			description = "Create Interface file",
		},
		ResSwitchImplInt = {
			require("rescript-tools").switch_impl_intf,
			description = "Switch Implementation/Interface",
		},
	},
}

-- need to edit: server/out/server.js
--[[
let extensionConfiguration = {
  allowBuiltInFormatter: false,
  askToStartBuild: false,
  inlayHints: {
    enable: false,
    maxLength: 25,
  },
  codeLens: true,
  binaryPath: null,
  platformPath: null,
  signatureHelp: {
    enabled: true,
  },
};
--]]
--
--[[
onMessage(msg){
  ...
 tokenTypes: [
                "operator",
                "variable",
                "type",
                "modifier", // emit jsx-tag < and > in <div> as modifier
                "namespace",
                "enumMember",
                "property",
                "interface", // emit jsxlowercase, div in <div> as interface
              ],
]]
--
