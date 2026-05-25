Here is the complete execution of your tasks for your modular Neovim configuration.

Per your exact guidelines, files requested to be rewritten are output in full (`theme.lua`, `ui.lua`, `git.lua`, `markdown.lua`, `latex.lua`, and `README.md`), while all other tasks list precise, isolated changes to remain entirely modular and avoid overwriting any unmentioned code blocks.

---

### 🛠️ Task 1: Create a Separate `theme.lua` File

This new file separates your theme layer cleanly. It establishes global access to a cohesive palette via `_G.QPalette` while loading the **Catppuccin Mocha** environment with optimized overrides for modern UI rendering.

**Create a new file named `theme.lua` (place inside your plugins directory):**

```lua
-- theme.lua
local M = {
  {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local catppuccin = require("catppuccin")
      catppuccin.setup({
        flavour = "mocha",
        transparent_background = false,
        highlight_overrides = {
          mocha = function(colors)
            return {
              -- Gitsigns high-density visual markers
              GitSignsAdd = { fg = colors.green, bg = colors.none },
              GitSignsChange = { fg = colors.yellow, bg = colors.none },
              GitSignsDelete = { fg = colors.red, bg = colors.none },

              -- Task 4: Gitsigns Line & Number Highlights matching the theme palette
              GitSignsAddLn = { bg = "#2e3b30" },     -- Subtle green background for added block
              GitSignsChangeLn = { bg = "#3f3e2d" },  -- Subtle yellow background for changed block
              GitSignsDeleteLn = { bg = "#3d2a2d" },  -- Subtle red background for deleted block
              GitSignsAddNr = { fg = colors.green, bold = true },
              GitSignsChangeNr = { fg = colors.yellow, bold = true },
              GitSignsDeleteNr = { fg = colors.red, bold = true },

              -- Task 8 & 9: NvChad-style flat borderless layout for Telescope
              TelescopeBorder = { fg = colors.mantle, bg = colors.mantle },
              TelescopeNormal = { bg = colors.mantle },
              TelescopePreviewBorder = { fg = colors.crust, bg = colors.crust },
              TelescopePreviewNormal = { bg = colors.crust },
              TelescopePromptBorder = { fg = colors.surface0, bg = colors.surface0 },
              TelescopePromptNormal = { bg = colors.surface0 },
              TelescopePromptPrefix = { fg = colors.red, bg = colors.surface0 },
              TelescopeSelection = { bg = colors.surface1, fg = colors.text },

              -- NvChad-style statusline and floating window accents
              NormalFloat = { bg = colors.mantle },
              FloatBorder = { fg = colors.surface1, bg = colors.mantle },
            }
          end,
        },
        integrations = {
          blink_cmp = true,
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
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  }
}

-- Globally accessible theme variables across the configuration environment
_G.QPalette = {
  bg        = "#1e1e2e",
  fg        = "#cdd6f4",
  red       = "#f38ba8",
  green     = "#a6e3a1",
  yellow    = "#f9e2af",
  blue      = "#89b4fa",
  magenta   = "#cba6f7",
  cyan      = "#89dceb",
  orange    = "#fab387",
  surface0  = "#313244",
  surface1  = "#45475a",
  mantle    = "#181825",
  crust     = "#11111b",
}

return M

```

_Note: Remember to update your `init.lua` file inside the `lazy.setup` function block to include `{ import = "plugins.theme" }` so the manager loads the theme module._

---

### 🎨 Task 2: Rewrite `ui.lua`

The entire `ui.lua` file has been stripped of the colorscheme blocks (now residing in `theme.lua`), keeping structural layout trackers perfectly organized.

```lua
-- ui.lua
return {
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
          "snacks_dashboard", -- FIX #10: snacks.nvim dashboard filetype
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
          if bt == "nofile" or bt == "terminal" or bt == "quickfix" then
            vim.b.miniindentscope_disable = true
          end
        end,
      })
    end,
  },
}

```

---

### ⌨️ Task 3: Arrow Key Delay Fix

The delay when holding down arrow keys occurs because Neovim intercepts terminal Escape sequences (which are emitted by physical arrow keys) and pauses to wait and see if they complete a multi-key user mapping combination.

**Add this configuration line into your existing `options.lua` file:**

```lua
vim.opt.ttimeoutlen = 10 -- Cuts the escape sequence response latency down instantly

```

---

### 🌿 Task 4: Git Configuration & Rewrite

#### Conceptual Deep-Dive

- **`topdelete = { text = "⎴" }`**: Identifies a git removal block occurring at the very top boundary of a file where lines were removed before line 1.
- **`changedelete = { text = "▍" }`**: Identifies a complex hybrid modification block where active modifications combined with a deletion happen within the same git hunk tracker.
- **`untracked = { text = "┆" }`**: Identifies a newly introduced file or line additions inside a code file that hasn't been added to the Git index yet.
- **`linehl = false` / `numhl = false**`: When active, these attributes toggle background highlighting overlays on the whole text line layout (`linehl`) or text-color accents matching the file sequence indicators directly over the line numbers column layout (`numhl`).

#### Justification for Removing `diffview.nvim`

`diffview.nvim` provides a massive split-tab structural overview window designed for repository-wide index review tracking. For an architecture designed for raw velocity, `diffview.nvim` introduces substantial runtime setup overhead. By offloading complex repository management tasks to `vim-fugitive` (via `:Git`) and managing structural file modifications directly inside the buffer layout using modern line highlighting, `diffview.nvim` becomes redundant.

```lua
-- git.lua
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▎" },
        topdelete    = { text = "▎" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      linehl = true, -- Toggles subtle background line highlights
      numhl = true,  -- Toggles line number highlight accents in the gutter
      attach_to_untracked = true,
      watch_gitdir = { follow_files = true },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function() gs.stage_hunk { vim.fn.line ".", vim.fn.line "v" } end, \"Stage hunk (visual)\")
        map("v", "<leader>hr", function() gs.reset_hunk { vim.fn.line ".", vim.fn.line "v" } end, \"Reset hunk (visual)\")
        map("n", "<leader>hS", gs.stage_buffer, \"Stage buffer\")
        map("n", "<leader>hR", gs.reset_buffer, \"Reset buffer\")
        map("n", "<leader>hp", gs.preview_hunk, \"Preview hunk\")
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, \"Blame line\")
        map("n", "<leader>hd", gs.diffthis, \"Diff this\")
        map("n", "<leader>hD", function() gs.diffthis \"~\" end, \"Diff this ~\")
        map({ \"o\", \"x\" }, \"ih\", \":<C-U>Gitsigns select_hunk<CR>\", \"Select inside hunk\")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git", "G", "Gdiffsplit", "Gread", "Gwrite", "Ggrep", "GMove",
      "GDelete", "GBrowse", "GRemove", "GRename", "Glgrep", "Gedit"
    },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" } },
  },
}

```

---

### 📝 Task 5: Markdown Environment Transformation

This module fully transforms Neovim into a capable Markdown workstation. Folding handles are stripped, `render-markdown` is upgraded to modern standards, auto-pairing for ``expansions (in sets of 2, 4, 6) is configured via smart buffer macros, and pressing`-` automatically expands into standard separation dividers (`---`) with instant line returns.

Additionally, it integrates a declarative template generation hook that ensures any directory containing an opened Markdown file will seamlessly configure a local `.markdownlint-cli2.yaml` environment if one isn't present, without ever wiping or modifying your pre-existing rules.

```lua
-- markdown.lua
vim.api.nvim_create_autocmd({ "BufNewFile", "BufReadPost" }, {
  pattern = { "*.md", "*.markdown" },
  callback = function()
    -- Task 14: Smart Typography & visual text wrapping for prose documents
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 0

    -- Visual navigation for soft wrapped rows
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })

    -- Task 5: Smart ** auto-pair sequence generation blocks (Generates 2, 4, 6 entries dynamically)
    vim.keymap.set("i", "**", "****<Left><Left>", { buffer = true, silent = true })
    vim.keymap.set("i", "****", "******<Left><Left><Left>", { buffer = true, silent = true })
    vim.keymap.set("i", "******", "********<Left><Left><Left><Left>", { buffer = true, silent = true })

    -- Task 5: Horizontal divider macro string expansion layout block with inline carriage return
    vim.keymap.set("i", "-", function()
      local col = vim.fn.col(".")
      local line = vim.fn.getline(".")
      if col == 1 or line:sub(1, col-1):match("^%s*$") then
        return "---<CR>"
      else
        return "-"
      end
    end, { buffer = true, expr = true, silent = true })

    -- Automated `.markdownlint-cli2.yaml` declaration safety-guard lifecycle hook
    local current_dir = vim.fn.expand("%:p:h")
    if current_dir and current_dir ~= "" then
      local target_yaml = current_dir .. "/.markdownlint-cli2.yaml"
      if vim.fn.filereadable(target_yaml) == 0 then
        local default_rules = {
          "config:",
          "  default: true",
          "  MD013: false", -- Disable line length rules for soft-wrap environments
          "  MD033: false", -- Allow inline custom HTML tags
          "  MD007: { indent: 2 }",
        }
        vim.fn.writefile(default_rules, target_yaml)
      end
    end
  end,
})

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      heading = {
        sign = true,
        icons = { "󰉫 ", "󰉬 ", "󰉭 ", "󰉮 ", "󰉯 ", "󰉰 " },
        backgrounds = {
          "RenderMarkdownH1Bg", "RenderMarkdownH2Bg", "RenderMarkdownH3Bg",
          "RenderMarkdownH4Bg", "RenderMarkdownH5Bg", "RenderMarkdownH6Bg"
        },
      },
      code = {
        sign = false,
        width = "block",
        right_pad = 4,
        left_pad = 4,
        border = "rounded",
      },
      pipe_table = { preset = "round" },
      checkbox = {
        unchecked = { icon = "󰄱 " },
        checked = { icon = " " },
      },
    },
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown", "md" },
    cmd = { "TableModeToggle" },
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "BufEnter *.md",
    opts = {
      default = {
        dir_path = "assets",
        extension = "png",
        arm_sync = true,
      },
    },
    keys = {
      { "<leader>mp", "<cmd>PasteImage<cr>", desc = "Paste Image from Clipboard" },
    },
  },
}

```

---

### 🧼 Task 6: Native Command-Line Restoration

To dismantle the customized center-screen floating command line and fall back entirely to native Neovim standard bottom rows behavior, you need to remove `noice.nvim` from your plugin environment layer.

**Locate where `noice.nvim` is added in your configuration and delete it entirely.** If it's loaded as part of a plugin file bundle or inside your tool wrappers, delete the specification table entirely. Ensure your updated `theme.lua` (Task 1) keeps `noice = false` or leaves it unassigned under the theme integration setups.

---

### 🔄 Task 7: Tab Completion & Auto-Accept Setup

To enforce cycling navigation through matching candidates via `<Tab>` and `<S-Tab>`, and have highlighting an entry instantly update your buffer without manual key trigger interventions, adjust your `blink.cmp` config.

**Apply these properties directly inside the `opts` layout block of your `completion.lua` file:**

```lua
-- Add/replace these configuration options within blink.cmp opts:
opts = {
  keymap = {
    preset = "none",
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  completion = {
    list = {
      selection = {
        preselect = false,
        auto_insert = true, -- Automatically enters highlighted items into the text fields
      },
    },
  },
}

```

---

### ⚡ Tasks 8 & 9: NvChad Visual Implementations

NvChad's clean aesthetic relies heavily on flat backgrounds, borderless visual partitions, unified floating windows, and customized highlight groups. These styles have been embedded inside your new global color overrides layer (`theme.lua`) under Task 1.

The `TelescopeBorder` and window groups are assigned to match the base shell layout tones (`colors.mantle` and `colors.crust`), resulting in a sleek, modern UI with floating panels, zero-clutter file view borders, and minimal visual noise without adding overhead.

---

### 📋 Task 10: Clipboard Register Preservation

By default, visual mode paste text replacement sequences instantly wipe out your copy buffer cache registers by overwriting them with the deleted line strings.

**Insert this mapping rule block inside your core `keymaps.lua` file:**

```lua
-- Visual mode paste text wrapper over existing code block sections without destroying registers
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting current selection text registers" })

```

---

### 🔬 Task 11: Create `latex.lua`

This file sets up a full LaTeX IDE using `vimtex` coupled with the standard Linux `texlive` application environment. Compilation tracking logs pass via the `texlab` LSP infrastructure server, and mathematical formatting frameworks render directly inline as clean ASCII/Unicode artwork block projections via `nabla.nvim`, optimized for Kitty terminal frameworks.

**Create a new file named `latex.lua` (place inside your plugins directory):**

```lua
-- latex.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "bib" },
  callback = function()
    -- Task 14: Smart Visual wrapping boundaries layout settings for Scientific papers
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.textwidth = 0
    vim.opt_local.wrapmargin = 0

    -- Gutter line indicators configurations mapping for text prose rows
    vim.keymap.set("n", "j", "gj", { buffer = true, silent = true })
    vim.keymap.set("n", "k", "gk", { buffer = true, silent = true })

    -- Quick inline mathematical previews shortcut triggers
    vim.keymap.set("n", "<leader>mp", function() require("nabla").toggle_virt() end, { buffer = true, desc = "Toggle Inline Math Formula Preview" })
  end,
})

return {
  {
    "lervag/vimtex",
    ft = { "tex", "latex" },
    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0 -- Keeps editor text lines fluid and responsive
    end,
  },
  {
    "jbyuki/nabla.nvim",
    ft = { "tex", "latex", "markdown" },
    desc = "Renders LaTeX mathematical formula notation characters directly inline within code panels",
  },
}

```

---

### 🚀 Task 12: Add Advanced Scientific Writing & IDE Plugins

To elevate your Neovim environment to a specialized IDE for scientific research and codebase architecture, add structural outlines and docstring management utilities.

**Create a new file named `ide_extensions.lua` (place inside your plugins directory):**

```lua
-- ide_extensions.lua
return {
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = { { "<leader>co", "<cmd>Outline<CR>", desc = "Toggle Code & Document Outline View Panel" } },
    opts = {},
  },
  {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true,
    keys = { { "<leader>cg", function() require("neogen").generate() end, desc = "Generate Production Docstrings / Annotations" } },
  },
}

```

---

### 🛡️ Task 13: Prevent Accidental Case Modifications (`u` Typo Fix)

To prevent accidentally modifying text casing when you miss the `y` key and press `u` in visual mode, we can bind `u` to safely mirror `y` instead. This turns a common typo into a functional feature while keeping standard case modifications accessible through the formal `gu` operator sequence.

**Add this safety mapping configuration block inside your core `keymaps.lua` file:**

```lua
-- Resolves the visual mode lowercase case mutation typo accident mapping
vim.keymap.set("v", "u", "y", { desc = "Prevent accidental lowercase text layout mutations; execute yank instead" })

```

---

### 🌊 Task 14: Smart Typography & Proportional Text Wrapping

The requirements for smart prose wrapping across specialized document file formats (`*.md`, `*.tex`, `*.bib`) have been built directly into the filetype initialization hooks within **Task 5** and **Task 11**.

These settings enforce non-breaking visual wrapping (`linebreak`), format paragraph indents accurately (`breakindent`), and completely disable rigid code-column terminations (`textwidth = 0`) to provide an absolute elite authoring experience.

---

### 📖 Task 15: Rewrite `README.md`

# 🌌 QuantumVim: Modular, Production-Grade IDE

A clean, blistering-fast, ideologically modular Neovim configuration built around Lua, optimized for modern software engineering and advanced scientific prose composition. This layout balances an aggressive, asynchronous plugin-loading architecture with deep language server workflows.

---

## 🎨 Philosophy & Core Framework

- **Decoupled Architecture:** System elements, options layouts, keymaps, and themes live inside clean modules to eliminate runtime dependencies and monolithic runtime files.
- **Asynchronous Execution Engine:** Powered by `blink.cmp` (Rust sorting loops), `conform.nvim` (non-blocking format lifecycles), and `gitsigns.nvim` for immediate UI rendering.
- **Scientific Authoring Suite:** Complete inline markdown engines, standard Linux `texlive` workflows with `vimtex`, and fast `zathura` PDF sync trackers.
- **NvChad Visuals:** Flat borderless configurations, minimalist layouts, and clean window structures for long engineering sessions.

---

## 🏗️ Directory Architecture

```text
~/.config/nvim/
├── init.lua                 # Runtime Bootstrapper & Lazy Engine Setup
├── options.lua              # Global System Variables & Timing Flags
├── keymaps.lua              # Clipboard Protections & Safety Bindings
├── autocmds.lua             # Global File Event Operational Lifecycles
├── selene.toml              # Strict Lua Verification Code Linter Configurations
└── lua/plugins/
    ├── theme.lua            # Catppuccin Palette Core & NvChad Elements Overrides
    ├── ui.lua               # Indentation Visual Trackers & Gutter Elements
    ├── completion.lua       # Blink.cmp Fast Tab Cycling Logic Modules
    ├── lsp.lua              # Diagnostic Navigation & Troubleshoot Viewers
    ├── mason.lua            # Automatic Package Manager Tool Setup Installs
    ├── formatter.lua        # Conform Async Auto-Format Pipeline Triggers
    ├── lint.lua             # Nvim-Lint Structural Code Engine Analysts
    ├── git.lua              # High-Density Line Gitsigns Highlighters
    ├── markdown.lua         # Smart Typography, Pairs, & Automated Local Linters
    ├── latex.lua            # Vimtex LaTeX Compiler & Inline Math Render Engines
    ├── ide_extensions.lua   # Visual Structural Outline Frameworks
    └── tools.lua            # Telescope, Neo-Tree Explorer & Search Mechanics
```

---

## ⚙️ Key Architectural Implementations

### 🎨 Theme & Global Color Palette (`theme.lua`)

The colorscheme layer is fully decoupled from plugin code tables, managing visual properties cleanly. It exposes `_G.QPalette` for absolute configuration consistency and applies an elegant flat, borderless NvChad-style structure to Telescope and floating windows.

### 📝 Capable Markdown Editor (`markdown.lua`)

Rigid folding rules are replaced with soft visual text-wrapping setups. Typing ``automatically pairs text selectors dynamically in sets of 2, 4, 6, and a single`-`expands instantly to`---`dividers with inline returns. Additionally, opening Markdown files automatically generates an isolated`.markdownlint-cli2.yaml` environment template within the directory to enforce local text styling rules safely.

### 🔬 Comprehensive LaTeX Environment (`latex.lua`)

Provides a complete workspace utilizing your system's `texlive` packages alongside automated `texlab` LSP background engines. Compilations run through `latexmk` and display immediately within the `zathura` viewer, while mathematical formulas and notation strings compile instantly as readable inline artwork previews right inside your editor view buffer via `<leader>mp`.

### ⚡ Smart Completion Lifecycles (`completion.lua`)

Blink.cmp handles suggestions asynchronously with custom tab routing: `<Tab>` cycles down candidate selectors, while `<S-Tab>` moves back upward. Highlighting any list selection automatically inputs it directly into the active document row, removing extra keyboard confirmation steps.

### 🛡️ Safety Maps & Registers (`keymaps.lua`)

- **Visual Paste Protection**: Pasting visual selections over existing text blocks automatically handles replacements using the blackhole register (`"_dP`), keeping your primary yank buffer completely intact for multiple consecutive paste actions.
- **Visual lowercase typo-protection**: Accidental triggers of `u` within visual selections are routed to mirror `y` (yank), preventing unintended lowercase text mutations while preserving formal `gu` updates.
- **Latency-Free Holds**: Arrow navigation latency drops down immediately via `ttimeoutlen = 10`, ensuring smooth cursor movement when holding down navigation keys.
