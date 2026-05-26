return {
  -- ── Statusline ───────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      local colors = require("catppuccin.palettes").get_palette("mocha")
      require("lualine").setup({
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = {
            {
              "mode",
              separator = { left = "" },
              right_padding = 2,
              color = { fg = colors.crust, bg = colors.blue, gui = "bold" },
            },
          },
          lualine_b = {
            { "branch", icon = "", color = { fg = colors.maroon, bg = colors.surface0 } },
          },
          lualine_c = { { "filename", color = { fg = colors.text, bg = colors.surface0 } } },
          lualine_x = {
            {
              "diagnostics",
              sources = { "nvim_diagnostic" },
              color = { fg = colors.text, bg = colors.surface0 },
            },
          },
          lualine_y = { { "filetype", color = { fg = colors.text, bg = colors.surface0 } } },
          lualine_z = {
            {
              "location",
              separator = { right = "" },
              left_padding = 2,
              color = { fg = colors.crust, bg = colors.blue },
            },
          },
        },
        inactive_sections = {
          lualine_c = { { "filename", color = { fg = colors.overlay0, bg = colors.base } } },
          lualine_x = { { "location", color = { fg = colors.overlay0, bg = colors.base } } },
        },
      })
    end,
  },

  -- ── Bufferline ───────────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = { "catppuccin/nvim" }, -- Forces catppuccin to load before bufferline
    config = function()
      -- Safely check if catppuccin's bufferline integration module is available
      local has_catppuccin, catppuccin_bufferline = pcall(require, "catppuccin.groups.integrations.bufferline")
      local highlights = has_catppuccin and catppuccin_bufferline.get() or {}

      require("bufferline").setup({
        options = {
          mode = "buffers",
          separator_style = "thin",
          -- Add any other custom bufferline options you have below:
          offsets = {
            {
              filetype = "neo-tree",
              text = "File Explorer",
              text_align = "left",
              separator = true,
            },
          },
        },
        -- Use the safely resolved highlights table here
        highlights = highlights,
      })
    end,
  },

  -- ── Icons ────────────────────────────────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- ── Noice (cmdline pinned to bottom, NvChad-style) ───────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        cmdline = { enabled = true },
        messages = { enabled = true },
        popupmenu = { enabled = true },
        views = {
          -- Bottom-anchored cmdline popup (NvChad style).
          -- command_palette preset is disabled below so this position is respected.
          cmdline_popup = {
            position = { row = "100%", col = 0 },
            size = { width = "100%", height = "auto" },
          },
        },
        lsp = {
          progress = { enabled = false },
          override = {
            -- FIX #8: removed ["cmp.entry.get_documentation"] = true
            -- That key is for nvim-cmp, which is not installed.
            -- These two are the only valid overrides with blink.cmp:
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        presets = {
          bottom_search = false,
          -- FIX #7: command_palette = true overrides the cmdline_popup position
          -- set in `views` above (presets have higher merge priority than views).
          -- Disabling it lets the bottom placement take effect.
          command_palette = false,
          long_message_to_split = true,
          inc_rename = false,
          lsp_doc_border = true,
        },
      })
    end,
  },

  -- ── Notifications ────────────────────────────────────────────────────────
  {
    "rcarriga/nvim-notify",
    lazy = true,
    config = function()
      require("notify").setup({
        background_colour = "#000000",
        timeout = 3000,
        render = "compact",
        stages = "fade_in_slide_out",
        max_width = 80,
      })
      -- FIX #9: do NOT set `vim.notify = require("notify")` here.
      -- noice.nvim owns vim.notify routing and directs notifications to
      -- nvim-notify as a backend. Manually assigning it races with noice's
      -- own hook and is silently overwritten anyway.
    end,
    init = function()
      vim.opt.fillchars:append({ eob = " " })
    end,
  },

  -- ── Indent guides ────────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    opts = { indent = { char = "│" }, scope = { enabled = false } },
  },
  {
    "echasnovski/mini.indentscope",
    event = "BufReadPost",
    version = "*",
    config = function()
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
        draw = { animation = require("mini.indentscope").gen_animation.none() },
      })

      -- Disable indentscope on UI/non-code filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "dashboard",
          "snacks_dashboard", -- FIX #10: snacks.nvim dashboard filetype (was missing)
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "Trouble",
          "trouble",
          "qf",
          "TelescopePrompt",
          "startify",
          "snacks_terminal",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      vim.api.nvim_create_autocmd("BufWinEnter", {
        callback = function()
          local bt = vim.bo.buftype
          if bt == "terminal" or bt == "nofile" or bt == "prompt" or bt == "quickfix" then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
  },
}
