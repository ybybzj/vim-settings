local dap = require("dap")

dap.adapters.lldb = {
	type = "executable",
	command = "/opt/homebrew/opt/llvm/bin/lldb-vscode",
	name = "lldb",
}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local lldb = {
	name = "Launch lldb",
	type = "lldb",
	request = "launch",
	-- program = function()
	-- 	return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
	-- end,
  program = function()
      return coroutine.create(function(coro)
        local opts = {}
        pickers
          .new(opts, {
            prompt_title = "Path to executable",
            finder = finders.new_oneshot_job({ "fd", "--hidden", "--no-ignore", "--type", "x" }, {}),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(buffer_number)
              actions.select_default:replace(function()
                actions.close(buffer_number)
                coroutine.resume(coro, action_state.get_selected_entry()[1])
              end)
              return true
            end,
          })
          :find()
      end)
    end,
	cwd = "${workspaceFolder}",
	stopOnEntry = false,
	args = {},
	runInTerminal = false, -- should not chang it
	env = function()
		local variables = {}
		for k, v in pairs(vim.fn.environ()) do
			table.insert(variables, string.format("%s=%s", k, v))
		end
		return variables
	end,
}

dap.configurations.zig = {
	lldb,
}
dap.configurations.rust = {
	lldb,
}

local map = vim.keymap.set

vim.keymap.set("n", "<F9>", function()
	dap.continue()
end)
map("n", "<F10>", function()
	dap.step_over()
end)
map("n", "<F11>", function()
	dap.step_into()
end)
map("n", "<F12>", function()
	dap.step_out()
end)

map("n", "<leader>b", function()
	dap.toggle_breakpoint()
end)

-- ux/ui
require("nvim-dap-virtual-text").setup()

local dapui = require("dapui")
dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

map('n', '<leader>d', function() 
  dapui.toggle()
end)
