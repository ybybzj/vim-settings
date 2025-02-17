return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
          ensure_installed = { 
          	"c",
            "lua",
            "rust",
            "zig",
            "javascript",
            "typescript",
            "go",
            "css",
            "html",
            "tsx",
            "toml",
            "yaml",
            "markdown",
            "markdown_inline",
          },
          sync_install = false,
          highlight = { enable = true },
          indent = { enable = true },  

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "gnn",
        node_incremental = "grn",
        scope_incremental = "grc",
        node_decremental = "grm",
      },
    },
    matchup = { enable = true },
    autopairs = { enable = true },
    textobjects = {
      select = {
        enable = true,

        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,

        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@call.outer",
          ["ic"] = "@call.inner",
          ["ib"] = "@block.inner",
          ["ab"] = "@block.outer",
          ["ip"] = "@parameter.inner",
          ["ap"] = "@parameter.outer",

          -- Or you can define your own textobjects like this
          -- ["iF"] = {
          -- 	python = "(function_definition) @function",
          -- 	cpp = "(function_definition) @function",
          -- 	c = "(function_definition) @function",
          -- 	java = "(method_declaration) @function",
          -- },
        },
      },
      move = {
        enable = true,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          ["]m"] = "@function.outer",
          ["]]"] = "@class.outer",
        },
        goto_next_end = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
      },
    }
        })
    end
},
	"nvim-treesitter/nvim-treesitter-textobjects",
	"JoosepAlviste/nvim-ts-context-commentstring",
}
