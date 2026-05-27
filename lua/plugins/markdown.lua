-- lua/plugins/markdown.lua

-- ── Highlight Definitions ─────────────────────────────────────────────────────
-- Safely queries Catppuccin's native module at runtime when applied or re-applied
-- on ColorScheme events, completely eliminating global variable dependencies.
local function define_highlights()
  local has_catppuccin, cp_palettes = pcall(require, "catppuccin.palettes")
  if not has_catppuccin then
    return
  end

  local c = cp_palettes.get_palette("mocha") or {}
  if next(c) == nil then
    return
  end

  local hl = function(name, opts)
    opts.default = true -- yield to colorscheme if it defines the group itself
    vim.api.nvim_set_hl(0, name, opts)
  end

  -- ── Heading foregrounds ──────────────────────────────────────────────────
  hl("RenderMarkdownH1", { fg = c.red, bold = true })
  hl("RenderMarkdownH2", { fg = c.peach, bold = true })
  hl("RenderMarkdownH3", { fg = c.yellow, bold = true })
  hl("RenderMarkdownH4", { fg = c.green, bold = true })
  hl("RenderMarkdownH5", { fg = c.sky, bold = true })
  hl("RenderMarkdownH6", { fg = c.lavender, bold = true })

  -- ── Heading backgrounds — barely-there tints, one shade above base ───────
  --   No border means these are the sole visual weight of each heading level.
  --   Kept very dark so the foreground colour carries the hierarchy signal.
  hl("RenderMarkdownH1Bg", { bg = "#261e22" }) -- barely-rose
  hl("RenderMarkdownH2Bg", { bg = "#241d16" }) -- barely-peach
  hl("RenderMarkdownH3Bg", { bg = "#232112" }) -- barely-yellow
  hl("RenderMarkdownH4Bg", { bg = "#131e13" }) -- barely-green
  hl("RenderMarkdownH5Bg", { bg = "#101b20" }) -- barely-sky
  hl("RenderMarkdownH6Bg", { bg = "#171726" }) -- barely-lavender

  -- ── Code blocks ──────────────────────────────────────────────────────────
  hl("RenderMarkdownCode", { bg = c.mantle })
  hl("RenderMarkdownCodeBorder", { fg = c.surface1 }) -- thin cap line
  hl("RenderMarkdownCodeInline", { bg = c.surface1, fg = c.mauve })

  -- ── Horizontal rule ──────────────────────────────────────────────────────
  hl("RenderMarkdownDash", { fg = c.surface2 })

  -- ── Block quotes — cycling per nesting level ─────────────────────────────
  hl("RenderMarkdownQuote1", { fg = c.blue })
  hl("RenderMarkdownQuote2", { fg = c.mauve })
  hl("RenderMarkdownQuote3", { fg = c.teal })
  hl("RenderMarkdownQuote4", { fg = c.green })
  hl("RenderMarkdownQuote5", { fg = c.yellow })
  hl("RenderMarkdownQuote6", { fg = c.peach })

  -- ── Bullets ──────────────────────────────────────────────────────────────
  hl("RenderMarkdownBullet", { fg = c.overlay1 })

  -- ── Tables ───────────────────────────────────────────────────────────────
  hl("RenderMarkdownTableHead", { fg = c.sapphire, bold = true })
  hl("RenderMarkdownTableRow", { fg = c.text })

  -- ── Checkboxes ───────────────────────────────────────────────────────────
  hl("RenderMarkdownUnchecked", { fg = c.overlay1 })
  hl("RenderMarkdownChecked", { fg = c.green })
  hl("RenderMarkdownTodo", { fg = c.yellow })

  -- ── Links ────────────────────────────────────────────────────────────────
  hl("RenderMarkdownLink", { fg = c.sky, underline = true })
  hl("RenderMarkdownWikiLink", { fg = c.teal, underline = true })

  -- ── Inline highlight (==text==) ───────────────────────────────────────────
  hl("RenderMarkdownInlineHighlight", { bg = c.surface1, fg = c.peach })

  -- ── Callout severity colours ─────────────────────────────────────────────
  hl("RenderMarkdownSuccess", { fg = c.green })
  hl("RenderMarkdownHint", { fg = c.teal })
  hl("RenderMarkdownInfo", { fg = c.blue })
  hl("RenderMarkdownWarn", { fg = c.yellow })
  hl("RenderMarkdownError", { fg = c.red })
end

-- Establish baseline highlights and hook into future layout refreshes
define_highlights()
vim.api.nvim_create_autocmd("ColorScheme", { callback = define_highlights })

-- ── Automated Buffer Setup ────────────────────────────────────────────────────
local function setup_markdown_buffer()
  -- ── Display options ───────────────────────────────────────────────────────
  vim.opt_local.conceallevel = 2 -- hide markup; required by render-markdown
  vim.opt_local.concealcursor = "nc" -- keep conceal in Normal+Cmd; reveal in Insert
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true -- wrap at word boundaries
  vim.opt_local.breakindent = true -- wrapped lines keep parent indent
  vim.opt_local.showbreak = "  " -- 2-space leader on continuation lines
  vim.opt_local.spell = true
  vim.opt_local.spelllang = "en_us"

  -- ── Bold autopair  **|** ────────────────────────────────────────────────
  vim.keymap.set("i", "**", "****<Left><Left>", { buffer = true, silent = true, desc = "Markdown: bold pair **|**" })

  -- ── Italic autopair  __|__  ──────────────────────────────────────────────
  vim.keymap.set("i", "__", "____<Left><Left>", { buffer = true, silent = true, desc = "Markdown: italic pair __|__" })

  -- ── Horizontal rule  ---<CR>  ─────────────────────────────────────────────
  vim.keymap.set("i", "---", "---<CR>", { buffer = true, silent = true, desc = "Markdown: horizontal rule + newline" })

  -- ── mini.pairs: markdown-specific buffer pairs ────────────────────────────
  local ok, _ = pcall(require, "mini.pairs")
  if ok and MiniPairs then
    MiniPairs.map_buf(0, "i", "$", {
      action = "closeopen",
      pair = "$$",
      register = { cr = false }, -- $...$ math blocks don't expand on <CR>
    })
  end

  -- ── Non-destructive .markdownlint-cli2.yaml creation ─────────────────────
  local buf_name = vim.api.nvim_buf_get_name(0)
  if buf_name ~= "" then
    local dir = vim.fn.fnamemodify(buf_name, ":h")
    local config_path = dir .. "/.markdownlint-cli2.yaml"

    if not vim.uv.fs_stat(config_path) then
      local template = [[# Declarative Markdown Linter Configuration
config:
  default: true
  MD013: false  # Line length handled by Neovim wrap; not enforced here
  MD033: false  # Allow inline HTML
  MD024: false  # Allow duplicate heading names (changelogs, etc.)
  MD041: false  # Don't require a top-level H1 in every file
]]
      local f = io.open(config_path, "w")
      if f then
        f:write(template)
        f:close()
      end
    end
  end
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = setup_markdown_buffer,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.md", "*.markdown" },
  callback = setup_markdown_buffer,
})

-- ── Plugin Specs (lazy.nvim) ──────────────────────────────────────────────────
return {
  ---------------------------------------------------------------------------
  -- render-markdown.nvim — in-buffer rendering via Neovim extmarks
  -- https://github.com/MeanderingProgrammer/render-markdown.nvim
  ---------------------------------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {
      render_modes = { "n", "c" },
      completions = { lsp = { enabled = true } },

      -- ── Anti-conceal — only expose the line the cursor is on ──────────
      --   (above=1/below=1 was unnecessarily chatty on short paragraphs)
      anti_conceal = {
        enabled = true,
        above = 0,
        below = 0,
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
          virtual_lines = true,
        },
      },

      padding = { highlight = "Normal" },

      win_options = {
        showbreak = { default = "", rendered = "  " },
        breakindent = { default = false, rendered = true },
        breakindentopt = { default = "", rendered = "" },
      },

      -- ── Headings ──────────────────────────────────────────────────────
      --   Removed ▄/▀ border framing — the coloured background strip and
      --   the nerd-font icon are enough hierarchy signal.
      --   Sign column also disabled: one less gutter element.
      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = false, -- no gutter icon per heading
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        position = "overlay",
        width = "full", -- full-width background gives a clean band
        border = false, -- no ▄/▀ cap lines above/below
        border_virtual = false,
        border_prefix = false,
        backgrounds = {
          "RenderMarkdownH1Bg",
          "RenderMarkdownH2Bg",
          "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg",
          "RenderMarkdownH5Bg",
          "RenderMarkdownH6Bg",
        },
        foregrounds = {
          "RenderMarkdownH1",
          "RenderMarkdownH2",
          "RenderMarkdownH3",
          "RenderMarkdownH4",
          "RenderMarkdownH5",
          "RenderMarkdownH6",
        },
      },

      -- ── Org-indent — disabled ─────────────────────────────────────────
      --   Per-level ▎ guide bars add visual noise to every body paragraph.
      indent = {
        enabled = false,
      },

      -- ── Code blocks ───────────────────────────────────────────────────
      --   "thin" border: single highlight line instead of thick ▄/▀ caps.
      --   "full" width: background stretches to the window edge, no
      --   floating-box jitter when lines have different lengths.
      --   Padding trimmed to one cell each side.
      code = {
        enabled = true,
        sign = false, -- no sign-column language badge
        style = "full",
        width = "full",
        border = "thin", -- subtle top/bottom rule, not ▄/▀ caps
        left_pad = 1,
        right_pad = 1,
        language_name = true,
        language_icon = true,
        highlight = "RenderMarkdownCode",
        highlight_border = "RenderMarkdownCodeBorder",
        highlight_inline = "RenderMarkdownCodeInline",
      },

      -- ── Horizontal rule ───────────────────────────────────────────────
      dash = {
        enabled = true,
        icon = "─",
        width = "full",
        highlight = "RenderMarkdownDash",
      },

      -- ── List bullets — 4-level cycling ───────────────────────────────
      --   Replaced heavy filled shapes (●◆) with lighter open/small ones.
      bullet = {
        enabled = true,
        icons = { "•", "◦", "‣", "⁃" },
        left_pad = 0,
        right_pad = 1,
        highlight = "RenderMarkdownBullet",
      },

      -- ── Checkboxes ────────────────────────────────────────────────────
      checkbox = {
        enabled = true,
        unchecked = { icon = "󰄱 ", highlight = "RenderMarkdownUnchecked" },
        checked = { icon = "󰱒 ", highlight = "RenderMarkdownChecked" },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },

      -- ── Block quotes ──────────────────────────────────────────────────
      --   ▏ (U+258F) is the thinnest block element — much quieter than ▋.
      quote = {
        enabled = true,
        icon = "▏",
        repeat_linebreak = true,
        highlight = {
          "RenderMarkdownQuote1",
          "RenderMarkdownQuote2",
          "RenderMarkdownQuote3",
          "RenderMarkdownQuote4",
          "RenderMarkdownQuote5",
          "RenderMarkdownQuote6",
        },
      },

      -- ── Callouts (GitHub / Obsidian style) ────────────────────────────
      callout = {
        note = { raw = "[!NOTE]", rendered = "󰋽 Note", highlight = "RenderMarkdownInfo" },
        tip = { raw = "[!TIP]", rendered = "󰌶 Tip", highlight = "RenderMarkdownSuccess" },
        important = { raw = "[!IMPORTANT]", rendered = "󰅾 Important", highlight = "RenderMarkdownHint" },
        warning = { raw = "[!WARNING]", rendered = "󰀪 Warning", highlight = "RenderMarkdownWarn" },
        caution = { raw = "[!CAUTION]", rendered = "󰳦 Caution", highlight = "RenderMarkdownError" },
        abstract = { raw = "[!ABSTRACT]", rendered = "󰨸 Abstract", highlight = "RenderMarkdownInfo" },
        info = { raw = "[!INFO]", rendered = "󰋽 Info", highlight = "RenderMarkdownInfo" },
        todo = { raw = "[!TODO]", rendered = "󰗡 Todo", highlight = "RenderMarkdownInfo" },
        hint = { raw = "[!HINT]", rendered = "󰴓 Hint", highlight = "RenderMarkdownHint" },
        success = { raw = "[!SUCCESS]", rendered = "󰄬 Success", highlight = "RenderMarkdownSuccess" },
        question = { raw = "[!QUESTION]", rendered = "󰘥 Question", highlight = "RenderMarkdownWarn" },
        bug = { raw = "[!BUG]", rendered = "󰨰 Bug", highlight = "RenderMarkdownError" },
        example = { raw = "[!EXAMPLE]", rendered = "󰉹 Example", highlight = "RenderMarkdownHint" },
        quote = { raw = "[!QUOTE]", rendered = "󱆨 Quote", highlight = "RenderMarkdownQuote1" },
      },

      -- ── Tables ────────────────────────────────────────────────────────
      --   preset = "round" supplies the rounded-corner box chars cleanly;
      --   no need for a hand-rolled 11-element border array.
      pipe_table = {
        enabled = true,
        render_modes = false,
        preset = "round",
        cell = "padded",
        padding = 1,
        min_width = 0,
        alignment_indicator = "━",
        head = "RenderMarkdownTableHead",
        row = "RenderMarkdownTableRow",
      },

      -- ── Links ─────────────────────────────────────────────────────────
      link = {
        enabled = true,
        footnote = { superscript = true, prefix = "", suffix = "" },
        image = "󰋩 ",
        email = "󰀓 ",
        hyperlink = "󰌹 ",
        highlight = "RenderMarkdownLink",
        wiki = {
          icon = "󱗖 ",
          highlight = "RenderMarkdownWikiLink",
        },
      },

      -- ── Sign column — globally off ────────────────────────────────────
      --   Individual components also set sign=false above; this is the
      --   catch-all for anything else that would touch the gutter.
      sign = {
        enabled = false,
      },

      -- ── Inline highlight (==text==) ───────────────────────────────────
      inline_highlight = {
        enabled = true,
        highlight = "RenderMarkdownInlineHighlight",
      },

      -- ── nofile buftype override ───────────────────────────────────────
      overrides = {
        buftype = {
          nofile = {
            render_modes = true,
            padding = { highlight = "NormalFloat" },
            sign = { enabled = false },
            code = { left_pad = 0, right_pad = 0 },
          },
        },
      },
    },
  },

  ---------------------------------------------------------------------------
  -- peek.nvim — live Deno-based HTML preview in a side window
  -- https://github.com/toppair/peek.nvim   (requires Deno)
  ---------------------------------------------------------------------------
  {
    "toppair/peek.nvim",
    ft = { "markdown" },
    build = "deno task --quiet build:fast",

    config = function()
      require("peek").setup({
        auto_load = false,
        close_on_bdelete = true,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview",
        filetype = { "markdown" },
        throttle_at = 200000,
        throttle_time = "auto",
      })

      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,

    keys = {
      {
        "<leader>mp",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        ft = "markdown",
        desc = "Markdown: Toggle Peek Preview",
      },
    },
  },
}
