-- Native TypeScript 7 (tsgo) resolver.
--
-- TypeScript 7 ships as a *native* binary; the npm package only carries a thin
-- JS shim (`lib/tsc.js`) that execve()s the platform binary. `lib/getExePath.js`
-- only exists in TS 7 packages, which is how we tell them apart from the TS 5/6
-- JS tsserver packages that older worktrees still use.
--
-- Why prefer tsgo: tsserver aborts with SIGABRT ("Allocation failed - JavaScript
-- heap out of memory") when a monorepo project load spikes past
-- --max-old-space-size. tsgo has no V8 heap cap, so a load spike cannot kill it.
-- See docs/typescript-lsp-tsgo.md.

local M = {}

---@type table<string, string[]|false>
local cache = {}

local function is_file(path)
	local stat = vim.uv.fs_stat(path)
	return stat ~= nil and stat.type == "file"
end

-- Maps `vim.uv.os_uname()` to the platform suffix used by the npm packages
-- (x86_64 -> x64, aarch64 -> arm64).
local function platform()
	local uname = vim.uv.os_uname()
	local arch = uname.machine
	if arch == "x86_64" then
		arch = "x64"
	elseif arch == "aarch64" then
		arch = "arm64"
	end
	return string.lower(uname.sysname), arch
end

--- Command list (without server args) for the native TS 7 server shipped in
--- `root`'s node_modules tree, or nil when the workspace has no native TS 7.
--- Walks up from `root` because pnpm hoists @typescript/* to the repo root.
---@param root string|nil
---@return string[]|nil
function M.command(root)
	if not root or root == "" then
		return nil
	end

	local cached = cache[root]
	if cached ~= nil then
		return cached == false and nil or cached
	end

	local dir = root
	while dir and dir ~= "" and dir ~= "/" do
		for _, pkg in ipairs({ "@typescript/native", "typescript" }) do
			local base = dir .. "/node_modules/" .. pkg
			if is_file(base .. "/lib/getExePath.js") and is_file(base .. "/lib/tsc.js") then
				cache[root] = { "node", base .. "/lib/tsc.js" }
				return cache[root]
			end
		end

		-- Fallback for installs that only hoist the platform binary (pnpm).
		local os_name, arch = platform()
		local name = "@typescript/typescript-" .. os_name .. "-" .. arch
		local pattern = dir
			.. "/node_modules/.pnpm/"
			.. name:gsub("/", "+")
			.. "@*/node_modules/"
			.. name
			.. "/lib/tsc"
		local matches = vim.fn.glob(pattern, false, true)
		if #matches > 0 then
			table.sort(matches)
			cache[root] = { matches[#matches] }
			return cache[root]
		end

		dir = vim.fs.dirname(dir)
	end

	local on_path = vim.fn.exepath("tsgo")
	cache[root] = on_path ~= "" and { on_path } or false
	return cache[root] or nil
end

--- `:VtsExec` requires a vtsls client. In tsgo workspaces vtsls is not running,
--- so guard these mappings instead of letting them error.
---@param sub string
function M.vts_exec(sub)
	if vim.lsp.get_clients({ name = "vtsls", bufnr = 0 })[1] then
		vim.cmd("VtsExec " .. sub)
	else
		vim.notify(
			"VtsExec " .. sub .. " is vtsls-only and no vtsls client is running in this workspace",
			vim.log.levels.WARN
		)
	end
end

return M
