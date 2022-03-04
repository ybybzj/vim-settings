local cmd = vim.cmd
local g =  vim.g
------------------theme-------------------------
cmd("set background=dark")
-- cmd("colorscheme material")
-- require("nord").set()

-- require("material").set()
-- g.material_style = "darker"

-- g["material_theme_style"] = "dark"
-- g["material_terminal_italics"] = 1
-- g["airline_powerline_fonts"] = 1

-- g.nightfox_style = "nightfox"
-- require("nightfox").set()

-- Available values: `'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`, `'espresso'`
g.sonokai_style = "atlantis"
g.sonokai_enable_italic = 1
g.sonokai_disable_italic_comment = 1
-- g.sonokai_transparent_background = 1
cmd("colorscheme sonokai")
