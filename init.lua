-- Faster module loading (Neovim 0.9+)
if vim.loader then
  vim.loader.enable()
end

-- Safe require with error handling
local function safe_require(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module .. ": " .. err, vim.log.levels.ERROR)
  end
end

safe_require("config.opts")
safe_require("config.keymaps")
safe_require("config.autocmds")
safe_require("config.lazy")
