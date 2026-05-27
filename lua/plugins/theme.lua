-- lua/plugins/theme.lua
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- High priority ensures it loads before other plugins
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        highlight_overrides = {
          mocha = function(cols)
            return {
              GitSignsAdd = { fg = cols.green, bg = cols.none },
              GitSignsChange = { fg = cols.yellow, bg = cols.none },
              GitSignsDelete = { fg = cols.red, bg = cols.none },
            }
          end,
        },
        integrations = {
          blink_cmp = true,
          noice = true,
          notify = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          illuminate = true,
          flash = true,
          neotree = true,
          snacks = { enabled = true },
          lualine = true,
          bufferline = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          mini = { enabled = true, indentscope_color = "" },
          dropbar = { enabled = true, color_mode = false },
        },
      })

      -- Apply the colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
