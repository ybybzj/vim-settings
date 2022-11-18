-- local cmd = vim.cmd
-- -- nerdtree --
-- cmd([[
--
-- let NERDTreeShowHidden=1
--
-- ]])

local status, neoTree = pcall(require, "neo-tree")

if not status then
	return
end

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
neoTree.setup({
	filesystem = {
		follow_current_file = true,
		hijack_netrw_behavior = "open_current",
    use_libuv_file_watcher = true
	},
})
