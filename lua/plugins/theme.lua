-- ── Global Color Palette Definition ────────────────────────────────────────
-- These variables are available globally across your entire Neovim configuration.
-- Currently configured with Catppuccin Mocha hex values.
_G.colors = {
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  subtext1 = "#bac2de",
  subtext0 = "#a6adc8",
  overlay2 = "#9399b2",
  overlay1 = "#7f849c",
  overlay0 = "#6c7086",
  surface2 = "#585b70",
  surface1 = "#45475a",
  surface0 = "#313244",
  base = "#1e1e2e",
  mantle = "#181825",
  crust = "#11111b",
  none = "NONE",
}

-- 💡 HOW TO ADD / CHANGE THEMES IN THE FUTURE:
-- 1. Replace the hex values in the `_G.colors` table above with your new theme's palette.
-- 2. Swap out the plugin repository string below (e.g., "folke/tokyonight.nvim")
--    and adjust its setup block accordingly.

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
