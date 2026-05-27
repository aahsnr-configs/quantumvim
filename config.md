# Neovim Configuration Files

## `init.lua`

```lua
-- Enable the experimental high-speed Lua byte-compiler cache
vim.loader.enable()

-- Initialize leader keys prior to executing any modular modules
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Explicitly load core operational lifecycles, options, and hotkeys
require("core.options")
require("core.keymaps")
require("core.autocmds")

-- Bootstrap the lazy.nvim package manager engine
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Initialize Lazy with a dynamic directory scanner targeting the plugins folder
require("lazy").setup({
  { import = "plugins" },                      -- Automatically scales to parse all nested plugin files
}, {
  checker = { enabled = true },                -- Periodically check for plugin updates asynchronously
  change_detection = { notify = true },        -- Send notifications when runtime configuration alters
  install = {
    colorscheme = { "catppuccin", "habamax" }, -- Resilient boot color states
  },
  performance = {
    rtp = {
      disabled_plugins = { -- Strip legacy and unneeded native distributions
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin", -- Bypassed in favor of Neo-Tree and Oil
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
```

## `neovim.yml`

```yaml
name: neovim
base: lua51
globals:
  # Core Neovim Entry Point
  vim:
    any: true

  # LuaJIT Architecture Extensions
  jit:
    any: true
  bit:
    any: true

  # Test Suite Globals (Plenary / Busted ecosystem support)
  describe:
    any: true
  it:
    any: true
  before_each:
    any: true
  after_each:
    any: true
  assert:
    any: true
```

## `selene.toml`

```toml
std = "neovim"

[lints]
# Style rules & structural layout patterns (allowed for flexibility)
global_usage = "allow"
mixed_table = "allow"
multiple_statements = "allow"
empty_if = "allow"
unscoped_variables = "allow"

# Static analysis logic checks (strict verification)
shadowing = "warn"
unused_variable = "warn"
incorrect_standard_library_use = "deny"
divide_by_zero = "deny"
unreachable_code = "deny"
duplicate_keys = "deny"
```

## `.markdownlint-cli2.yaml`

```yaml
# .markdownlint-cli2.yaml
# Rule configuration
config:
  default: true
  MD013: false # line length
  MD033: false # inline HTML allowed
  MD041: false # first line doesn't need top-level heading
  MD024: false # allow duplicate headings

# CLI-level options
fix: false
```

## `.stylua.toml`

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = true
```

## `autocmds.lua`

```lua
vim.g.autoformat = true -- Global configuration toggle state verified by conform.nvim

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local core_group = augroup("CoreAutocmds", { clear = true })

-- 1. High-speed Visual Flash on Text Yank
autocmd("TextYankPost", {
  group = core_group,
  desc = "Highlight yanked text momentarily",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- 2. Non-blocking Asynchronous Trailing White-space Pruning on Save
autocmd("BufWritePre", {
  group = core_group,
  pattern = "*",
  desc = "Prune trailing whitespace instances from text channels",
  callback = function(args)
    if not vim.bo[args.buf].modifiable then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- 3. Historical Cursor Position Alignment Restoration
autocmd("BufReadPost", {
  group = core_group,
  desc = "Re-align focus directly to last position mark on file load",
  callback = function()
    if vim.bo.filetype == "gitcommit" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      vim.api.nvim_win_set_cursor(0, mark)
    end
  end,
})

-- 4. Strip Persistent Inline Comment Continutions on Carriage Return
autocmd("FileType", {
  group = core_group,
  pattern = "*",
  desc = "Remove comment continuation tags from active format options",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- 5. Auto-equalize Active Display Windows on Scaling Resize
autocmd("VimResized", {
  group = core_group,
  desc = "Dynamically readjust layout bounds on host engine window resize",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- 6. Instant UI Exit Acceleration Macro for Overlay Viewports
autocmd("FileType", {
  group = core_group,
  pattern = { "help", "qf", "lspinfo", "man", "checkhealth" },
  desc = "Map 'q' to instantly shut down passive metadata panels",
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- 7. Optimized Interactive Terminal Focus Rules
-- autocmd("TermOpen", {
--   group = core_group,
--   desc = "Automate immediate insert entries inside terminal scopes and hide lines",
--   callback = function()
--     vim.opt_local.number = false
--     vim.opt_local.relativenumber = false
--     vim.cmd("startinsert")
--   end,
-- })
```

## `keymaps.lua`

```lua
local map = vim.keymap.set

-- ── Arrow Key Continuous Repeat Fix ────────────────────────────────────────
-- `nowait = true` forces immediate execution on the 1st press, bypassing
-- timeout lookaheads and allowing continuous holding to repeat instantly.
local arrow_opts = { remap = false, silent = true, nowait = true }

-- Normal & Visual Modes (Mapped directly to native motions)
map({ "n", "v" }, "<Up>", "k", arrow_opts)
map({ "n", "v" }, "<Down>", "j", arrow_opts)
map({ "n", "v" }, "<Left>", "h", arrow_opts)
map({ "n", "v" }, "<Right>", "l", arrow_opts)

-- Insert Mode (Preserves cursor navigation without breaking undo history)
map("i", "<Up>", "<Up>", arrow_opts)
map("i", "<Down>", "<Down>", arrow_opts)
map("i", "<Left>", "<Left>", arrow_opts)
map("i", "<Right>", "<Right>", arrow_opts)

-- ── Window Management & Splits ──────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize split sizes" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current split" })

-- Window Navigation Shortcuts
map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

-- ── Code & Line Manipulation ───────────────────────────────────────────────
-- Move current lines or visual selections up/down reactively
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- ── Editor Utilities ────────────────────────────────────────────────────────
-- High-speed escape fallback
map("i", "jk", "<esc>", { desc = "Exit insert mode" })

-- Clear active search highlighting
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
```

## `options.lua`

```lua
-- ── UI & View Layer ────────────────────────────────────────────────────────
vim.opt.number = true                                   -- Surface the absolute current line number
vim.opt.relativenumber = false                          -- Enable hybrid relative scaling for fast jumps
vim.opt.signcolumn = "yes"                              -- Lock sign column to prevent awkward element popping
vim.opt.cursorline = true                               -- Electronically illuminate the active screen line
vim.opt.termguicolors = true                            -- Unlock 24-bit RGB True Color spaces
vim.opt.showmode = false                                -- Supress legacy mode text; delegated to statuslines
vim.opt.cmdheight = 1                                   -- Keep screen estate clean for command responses
vim.opt.laststatus = 3                                  -- Anchor a single global statusline across split windows
vim.opt.showtabline = 0                                 -- Hide standard tab interfaces entirely
vim.opt.numberwidth = 3                                 -- Keep side gutter padding slim and predictable
vim.opt.pumheight = 10                                  -- Limit auto-completion list window sizes
vim.opt.completeopt = { "menu", "menuone", "noselect" } -- Modern popup mechanics
vim.opt.conceallevel = 0                                -- Keep decorative syntax rendering transparent by default
vim.opt.wrap = true                                     -- Soft-wrap lines longer than the window viewport
vim.opt.linebreak = true                                -- Hard break lines at word barriers instead of letters
vim.opt.breakindent = true                              -- Visual line continuations maintain indentation depths
-- vim.opt.smoothscroll = true      -- Elegant step scrolling when navigating long wrapped lines
vim.opt.scrolloff = 8                                   -- Guarantee spatial lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8                               -- Guarantee spatial columns left/right of cursor
vim.opt.fillchars = { eob = " " }                       -- Purge trailing tilde symbols from empty buffer tails

-- White-space Visualizers
vim.opt.list = true -- Track invisible structural characters
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── Structural Editing ──────────────────────────────────────────────────────
vim.opt.tabstop = 2               -- Number of visual columns an alignment tab occupies
vim.opt.shiftwidth = 2            -- Column width applied to structural block indentations
vim.opt.expandtab = true          -- Transparently transform standard tab entries into spaces
vim.opt.smarttab = true           -- Dynamic alignment shifts on starting lines
vim.opt.autoindent = true         -- Retain active indentation levels on new lines
vim.opt.virtualedit = "block"     -- Move cursor anywhere within visual block sequences
vim.opt.mouse = "a"               -- Retain mouse bindings across tracking scopes
vim.opt.clipboard = "unnamedplus" -- Connect directly to system clipboards

-- ── Search Matchers ─────────────────────────────────────────────────────────
vim.opt.ignorecase = true    -- Match case-insensitive query instances
vim.opt.smartcase = true     -- Override ignorecase if explicit capitals are specified
vim.opt.hlsearch = true      -- Maintain highlight indicators on all active matches
vim.opt.incsearch = true     -- Show query matches incrementally during entry
vim.opt.inccommand = "split" -- Render interactive preview panels during substitutions

-- ── Window Split Layouts ────────────────────────────────────────────────────
vim.opt.splitright = true -- Force horizontal splits to align rightward
vim.opt.splitbelow = true -- Force vertical splits to generate downward

-- ── Integrity & Persistence ─────────────────────────────────────────────────
vim.opt.undofile = true                             -- Activate persistent disk histories across sessions
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo" -- Directory targeting undo trees
vim.opt.swapfile = false                            -- Turn off standard recovery swap files
vim.opt.backup = false                              -- Avoid writing redundant operational back copies
vim.opt.writebackup = false                         -- Avoid locking files during write operations

-- ── Performance Core Timers ─────────────────────────────────────────────────
vim.opt.updatetime = 200       -- Diagnostic engine processing interval delay
vim.opt.timeoutlen = 300       -- Keybinding mapping sequence expiration length
vim.opt.autoread = true        -- Refresh external file changes automatically
vim.opt.fileencoding = "utf-8" -- Guarantee default unicode serialization
```

## `development.lua`

```lua
return {
  -- ==========================================================================
  -- 1. MASON PACKAGE MANAGEMENT & AUTOMATED TOOLING
  -- ==========================================================================
  {
    "mason-org/mason.nvim",
    config = true,
    cmd = "Mason",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "lua_ls",
        "basedpyright",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "gopls",
        "rust_analyzer",
        "bashls",
        "marksman",
        "texlab",
      },
      -- automatic_enable = true is the default in v2; no explicit flag needed.
      -- Installed servers are automatically enabled via vim.lsp.enable().
      -- NOTE: automatic_installation was removed in v2. Use ensure_installed instead.
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua",
        "ruff",
        "prettierd",
        "shfmt",
        "gofumpt",
        "goimports",
        "selene",
        "markdownlint-cli2",
        "yamllint",
        "jsonlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },

  -- ==========================================================================
  -- 2. COMPLETION ENGINE MODULE (BLINK.CMP & VISUAL EXTENSIONS)
  -- ==========================================================================
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- blink.lib removed: it is a V2-only dependency, not used in V1
      "rafamadriz/friendly-snippets",
      "xzbdmw/colorful-menu.nvim",
      { "saghen/blink.compat", opts = {} },
      "kdheepak/cmp-latex-symbols",
      "moyiz/blink-emoji.nvim",
      "mikavilpas/blink-ripgrep.nvim",
    },
    build = "cargo build --release",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
      end,

      cmdline = { enabled = true },

      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-u>"] = { "scroll_signature_up", "fallback" },
        ["<C-d>"] = { "scroll_signature_down", "fallback" },
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        keyword = {
          range = "full",
        },

        accept = { auto_brackets = { enabled = false } },

        list = {
          selection = {
            preselect = function(ctx)
              return vim.bo.filetype ~= "markdown"
            end,
            auto_insert = true,
          },
        },

        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },

        menu = {
          border = "none",
          draw = {
            columns = {
              { "kind_icon" },
              { "label", gap = 1 },
            },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },

      signature = { enabled = true },

      fuzzy = {
        implementation = "prefer_rust",
        prebuilt_binaries = { download = false }, -- Strictly rely on native compilation architecture
        sorts = { "score", "sort_text", "kind", "label" },
      },

      snippets = { preset = "default" },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          -- Explicitly list all sources for lua; inherit_defaults is a V2 feature
          lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
          markdown = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },
          tex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" }, -- LaTeX Integrated Context Mining
          plaintex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" }, -- LaTeX Integrated Context Mining
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          latex_symbols = {
            name = "latex_symbols",
            module = "blink.compat.source",
            score_offset = 2,
          },
          emoji = {
            name = "Emoji",
            module = "blink-emoji",
            score_offset = 1,
          },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            score_offset = 0,
          },
        },
      },
    },
  },

  -- ==========================================================================
  -- 3. CORE LANGUAGE RUNTIMES & INTERFACES (LSP)
  -- ==========================================================================
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, func, desc, extra_opts)
            extra_opts = extra_opts or {}
            local mode = extra_opts.mode or "n"
            extra_opts.mode = nil
            extra_opts.buffer = bufnr
            extra_opts.desc = "LSP: " .. desc
            vim.keymap.set(mode, keys, func, extra_opts)
          end

          -- ── Snacks Asynchronous Picker Mappings ─────────────────────────
          map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "Go to Definition")
          map("gr", function()
            Snacks.picker.lsp_references()
          end, "Go to References")
          map("gI", function()
            Snacks.picker.lsp_implementations()
          end, "Go to Implementation")

          -- Standard Core Operational Hooks
          map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { mode = { "n", "v" } })
          map("K", vim.lsp.buf.hover, "Hover Documentation")
        end,
      })

      -- Set blink.cmp capabilities globally for all servers in one call.
      -- vim.lsp.config('*', ...) merges into every server's config.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Per-server settings. nvim-lspconfig still provides the default
      -- root_dir, filetypes, and cmd values; we only override what differs.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enabled = false },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.config("marksman", {
        filetypes = { "markdown", "md" },
      })

      vim.lsp.config("html", {
        filetypes = { "html", "xhtml" },
        init_options = { provideFormatter = true },
      })

      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash" },
        settings = { bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" } },
      })

      vim.lsp.config("texlab", { -- LaTeX Integrated LSP Server Config
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = true,
            },
            forwardSearch = {
              executable = "zathura",
              args = { "--synctex-forward", "%l:1:%c", "%p" },
            },
            chktex = { onOpenAndSave = true, onType = false },
            diagnosticsDelay = 300,
          },
        },
      })

      -- ts_ls, cssls, jsonls, gopls, rust_analyzer use nvim-lspconfig defaults;
      -- only capabilities (set globally above) are needed.
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP (Trouble)" },
      {
        "<leader>ce",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Diagnostics: Describe Error at Cursor",
      },
      {
        "<leader>xe",
        "<cmd>Trouble diagnostics toggle filter.severity=ERROR<cr>",
        desc = "Diagnostics: Toggle All Errors",
      },
      {
        "<leader>cw",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.WARN })
        end,
        desc = "Diagnostics: Describe Warning at Cursor",
      },
      {
        "<leader>xw",
        "<cmd>Trouble diagnostics toggle filter.severity=WARN<cr>",
        desc = "Diagnostics: Toggle All Warnings",
      },
      {
        "<leader>xd",
        function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end,
        desc = "Diagnostics: Global Toggle On/Off",
      },
    },
  },

  -- ==========================================================================
  -- 4. WORKSPACE AUTOMATED FORMATTING LIFECYCLES (CONFORM)
  -- ==========================================================================
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
        markdown = { "prettierd" },
        html = { "prettierd" },
        css = { "prettierd" },
        scss = { "prettierd" },
        json = { "prettierd" },
        jsonc = { "prettierd" },
        yaml = { "prettierd" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        go = { "gofumpt", "goimports" },
        rust = { "rustfmt" },
        bash = { "shfmt" },
        tex = { "latexindent" },
        plaintex = { "latexindent" },
      },
      format_on_save = function(bufnr)
        if not vim.g.autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },

  -- ==========================================================================
  -- 5. ASYNCHRONOUS WORKSPACE LINTING OPERATIONS (NVIM-LINT)
  -- ==========================================================================
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      lint.linters.selene = lint.linters.selene or {}
      lint.linters.selene.args = {
        "--display-style",
        "quiet",
        "--config",
        vim.fn.expand("~/.config/nvim/selene.toml"),
      }

      lint.linters_by_ft = {
        lua = { "selene" },
        python = { "ruff" },
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        tex = { "chktex" },
        plaintex = { "chktex" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
```

## `git.lua`

```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Configured to use ONLY the uniform "▎" bar across all change definitions
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▎" },
        topdelete = { text = "▎" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged_enable = true,
      linehl = true, -- Enabled: Highlights full text line backgrounds
      numhl = true,  -- Enabled: Highlights line numbers in the gutter column
      attach_to_untracked = true,
      watch_gitdir = { follow_files = true },
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        -- Standard Hunk Operations & Mappings
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("v", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage hunk (visual)")
        map("v", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset hunk (visual)")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        -- Undo_stage_hunk was deprecated in commit 8b74e56 with the note
        -- "use stage_hunk() on staged signs". However, the community has found no clean behavioural equivalent yet (see gitsigns#1180, kickstart#1613). Keeping it as-is — it still works, just emits a deprecation warning. Revisit once gitsigns ships a proper unstage_hunk API.
        map("n", "<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
        map("n", "<leader>hd", gs.diffthis, "Diff this")
        map("n", "<leader>hD", function()
          gs.diffthis("~")
        end, "Diff this ~")

        -- Text Object for hunk selection
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select inside hunk")
      end,
    },
    config = function(_, opts)
      require("gitsigns").setup(opts)

      vim.schedule(function()
        local colors = _G.colors or {}
        if colors.green then
          -- 1. Gutter Signs (Foreground Symbols)
          vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = colors.green })
          vim.api.nvim_set_hl(0, "GitSignsChange", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = colors.red })
          vim.api.nvim_set_hl(0, "GitSignsTopdelete", { fg = colors.red })
          vim.api.nvim_set_hl(0, "GitSignsChangedelete", { fg = colors.yellow })
          vim.api.nvim_set_hl(0, "GitSignsUntracked", { fg = colors.green })

          -- 2. Line Number Colorizations (numhl)
          vim.api.nvim_set_hl(0, "GitSignsAddNr", { fg = colors.green, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsChangeNr", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsDeleteNr", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsTopdeleteNr", { fg = colors.red, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsChangedeleteNr", { fg = colors.yellow, bold = true })
          vim.api.nvim_set_hl(0, "GitSignsUntrackedNr", { fg = colors.green, bold = true })

          -- 3. Full-Line Background Shading (linehl)
          -- Uses low-intensity hex shades to maximize content legibility
          vim.api.nvim_set_hl(0, "GitSignsAddLn", { bg = "#2d3f34" })
          vim.api.nvim_set_hl(0, "GitSignsChangeLn", { bg = "#413f30" })
          vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { bg = "#43242a" })
          vim.api.nvim_set_hl(0, "GitSignsTopdeleteLn", { bg = "#43242a" })
          vim.api.nvim_set_hl(0, "GitSignsChangedeleteLn", { bg = "#413f30" })
          vim.api.nvim_set_hl(0, "GitSignsUntrackedLn", { bg = "#2d3f34" })
        end
      end)
    end,
  },

  -- ── Git Monolithic Command Utility ───────────────────────────────────────
  {
    "tpope/vim-fugitive",
    -- No changes needed. All commands below are current valid entries in the
    -- modern G-uppercase naming scheme. The lowercase aliases (Gread, Gwrite,
    -- Ggrep, Glgrep, Gedit, Gdiffsplit) are retained non-deprecated variants.
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "GMove",
      "GDelete",
      "GBrowse",
      "GRemove",
      "GRename",
      "Glgrep",
      "Gedit",
    },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" } },
  },
}
```

## `latex.lua`

```lua
return {
  -- ── Vimtex Framework (LaTeX Lifecycle Control Compiler) ──────────────────────
  {
    "lervag/vimtex",
    lazy = false, -- Vimtex internal engines manage their own optimization loops
    init = function()
      -- Configure view engine execution targets (Zathura PDF Reader standard)
      vim.g.vimtex_view_method = "zathura"

      -- Enable inline continuous parsing feedback mechanics
      vim.g.vimtex_compiler_method = "latexrun"

      -- Retain quiet structural compiler log echo parameters
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
```

## `markdown.lua`

```lua
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

  -- ── Heading backgrounds — dark tints crafted from each foreground ────────
  hl("RenderMarkdownH1Bg", { bg = "#32202a" }) -- dark rose tint
  hl("RenderMarkdownH2Bg", { bg = "#2e2018" }) -- dark peach tint
  hl("RenderMarkdownH3Bg", { bg = "#2d2914" }) -- dark yellow tint
  hl("RenderMarkdownH4Bg", { bg = "#162416" }) -- dark green tint
  hl("RenderMarkdownH5Bg", { bg = "#132228" }) -- dark sky tint
  hl("RenderMarkdownH6Bg", { bg = "#1d1d30" }) -- dark lavender tint

  -- ── Code blocks ──────────────────────────────────────────────────────────
  hl("RenderMarkdownCode", { bg = c.mantle })                       -- block fill (slightly darker than base)
  hl("RenderMarkdownCodeBorder", { fg = c.surface2 })               -- ▄/▀ cap chars (more visible than surface1)
  hl("RenderMarkdownCodeInline", { bg = c.surface1, fg = c.mauve }) -- `inline` (mauve pops on surface1)

  -- ── Horizontal rule ──────────────────────────────────────────────────────
  hl("RenderMarkdownDash", { fg = c.overlay0 })

  -- ── Block quotes — cycling per nesting level ─────────────────────────────
  hl("RenderMarkdownQuote1", { fg = c.blue })
  hl("RenderMarkdownQuote2", { fg = c.mauve })
  hl("RenderMarkdownQuote3", { fg = c.teal })
  hl("RenderMarkdownQuote4", { fg = c.green })
  hl("RenderMarkdownQuote5", { fg = c.yellow })
  hl("RenderMarkdownQuote6", { fg = c.peach })

  -- ── Bullets ──────────────────────────────────────────────────────────────
  hl("RenderMarkdownBullet", { fg = c.sapphire })

  -- ── Tables ───────────────────────────────────────────────────────────────
  hl("RenderMarkdownTableHead", { fg = c.sapphire, bold = true })
  hl("RenderMarkdownTableRow", { fg = c.text })

  -- ── Checkboxes ───────────────────────────────────────────────────────────
  hl("RenderMarkdownUnchecked", { fg = c.overlay1 })
  hl("RenderMarkdownChecked", { fg = c.green })
  hl("RenderMarkdownTodo", { fg = c.yellow })

  -- ── Links ────────────────────────────────────────────────────────────────
  hl("RenderMarkdownLink", { fg = c.sky, underline = true })
  hl("RenderMarkdownWikiLink", { fg = c.teal, underline = true }) -- [[wiki]] links

  -- ── Sign column ──────────────────────────────────────────────────────────
  hl("RenderMarkdownSign", { fg = c.overlay1 })

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
  vim.opt_local.conceallevel = 2     -- hide markup; required by render-markdown
  vim.opt_local.concealcursor = "nc" -- keep conceal in Normal+Cmd; reveal in Insert
  vim.opt_local.wrap = true
  vim.opt_local.linebreak = true     -- wrap at word boundaries
  vim.opt_local.breakindent = true   -- wrapped lines keep parent indent
  vim.opt_local.showbreak = "  "     -- 2-space leader on continuation lines
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
  pattern = "markdown", -- filetype NAME, not glob
  callback = setup_markdown_buffer,
})

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.md", "*.markdown" }, -- file-path GLOBS, not filetype names
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

      anti_conceal = {
        enabled = true,
        above = 1,
        below = 1,
        ignore = {
          code_background = true,
          indent = true,
          sign = true,
        },
      },

      padding = { highlight = "Normal" },

      win_options = {
        showbreak = { default = "", rendered = "  " },
        breakindent = { default = false, rendered = true },
        breakindentopt = { default = "", rendered = "" },
      },

      -- ── Headings ──────────────────────────────────────────────────────
      heading = {
        enabled = true,
        render_modes = false,
        atx = true,
        setext = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        signs = { "󰫎 " },
        position = "overlay",
        width = "full",
        border = true,
        border_virtual = true,
        border_prefix = true,
        above = "▄",
        below = "▀",
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

      -- ── Org-style body indentation ────────────────────────────────────
      indent = {
        enabled = true,
        per_level = 2,
        skip_level = 1,
        skip_heading = false,
      },

      -- ── Code blocks ───────────────────────────────────────────────────
      code = {
        enabled = true,
        sign = true,
        style = "full",
        width = "block",
        border = "thick",
        above = "▄",
        below = "▀",
        left_pad = 2,
        right_pad = 4,
        language_name = true,
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
      bullet = {
        enabled = true,
        icons = { "●", "○", "◆", "◇" },
        left_pad = 0,
        right_pad = 1,
        highlight = "RenderMarkdownBullet",
      },

      -- ── Checkboxes ────────────────────────────────────────────────────
      checkbox = {
        enabled = true,
        unchecked = {
          icon = "󰄱 ",
          highlight = "RenderMarkdownUnchecked",
        },
        checked = {
          icon = "󰱒 ",
          highlight = "RenderMarkdownChecked",
        },
        custom = {
          todo = { raw = "[-]", rendered = "󰥔 ", highlight = "RenderMarkdownTodo" },
        },
      },

      -- ── Block quotes ──────────────────────────────────────────────────
      quote = {
        enabled = true,
        icon = "▋",
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
      pipe_table = {
        enabled = true,
        render_modes = false,
        preset = "none",
        border = {
          "╭",
          "┬",
          "╮",
          "├",
          "┼",
          "┤",
          "╰",
          "┴",
          "╯",
          "│",
          "─",
        },
        border_enabled = true,
        border_virtual = false,
        cell = "padded",
        padding = 1,
        min_width = 0,
        alignment_indicator = "━",
        head = "RenderMarkdownTableHead",
        row = "RenderMarkdownTableRow",
        style = "full",
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

      -- ── Sign column ───────────────────────────────────────────────────
      sign = {
        enabled = true,
        highlight = "RenderMarkdownSign",
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
```

## `theme.lua`

```lua
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
```

## `todo.lua`

```lua
-- lua/plugins/todo.lua
-- Optimised Checkmate configuration for your Catppuccin + render-markdown stack.
-- https://github.com/bngarren/checkmate.nvim

return {
  {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- activate in all markdown buffers
    dependencies = {
      -- highlight re-apply on ColorScheme (already a core autocmd, listed for clarity)
    },
    opts = function()
      -- ── Highlight helpers (resilient to color scheme changes) ──────────
      local function set_highlights()
        -- Safely retrieve the live Catppuccin palette dynamically
        local has_catppuccin, cp_palettes = pcall(require, "catppuccin.palettes")
        if not has_catppuccin then
          return
        end

        local c = cp_palettes.get_palette("mocha") or {}
        if next(c) == nil then
          return
        end

        local hl = function(name, opts)
          opts.default = true -- yield to colorscheme if it defines the group
          vim.api.nvim_set_hl(0, name, opts)
        end

        hl("CheckmateTodoUnchecked", { fg = c.overlay1 })
        hl("CheckmateTodoChecked", { fg = c.green, strikethrough = true })
        hl("CheckmateTodoInProgress", { fg = c.yellow, bold = true })
        hl("CheckmateTodoOnHold", { fg = c.peach })
        hl("CheckmateTodoCancelled", { fg = c.surface2, strikethrough = true })

        hl("CheckmateMetaStarted", { fg = c.sky })
        hl("CheckmateMetaDone", { fg = c.green })
        hl("CheckmateMetaDue", { fg = c.red })
        hl("CheckmateMetaPriority", { fg = c.mauve })
      end

      -- Apply once now, then keep in sync on every future colorscheme change.
      set_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_highlights,
        group = vim.api.nvim_create_augroup("CheckmateHighlights", { clear = true }),
      })

      -- ── Core configuration ─────────────────────────────────────────────
      return {
        enabled = true,
        notify = true,

        -- Override the default narrow scope (todo.md, *.todo) to all markdown
        files = { "*.md", "*.markdown" },

        -- ── State markers ─────────────────────────────────────────────────
        -- Plain GFM markers so render-markdown can parse and overlay icons.
        -- The `name` field appears as optional virtual text next to the line.
        todo_states = {
          unchecked = {
            marker = "[ ]",
            name = "TODO",
            style = { hl_group = "CheckmateTodoUnchecked" },
          },
          checked = {
            marker = "[x]",
            name = "DONE",
            style = { hl_group = "CheckmateTodoChecked" },
          },
          custom = {
            {
              marker = "[-]",
              name = "IN-PROGRESS",
              style = { hl_group = "CheckmateTodoInProgress" },
            },
            {
              marker = "[~]",
              name = "ON-HOLD",
              style = { hl_group = "CheckmateTodoOnHold" },
            },
            {
              marker = "[/]",
              name = "CANCELLED",
              style = { hl_group = "CheckmateTodoCancelled" },
            },
          },
        },

        -- ── Metadata (inline @tags) ──────────────────────────────────────
        metadata = {
          started = {
            key = "started",
            label = "󰥔 started", -- nf-md-clock_outline
            hl_group = "CheckmateMetaStarted",
            on_state = { "IN-PROGRESS" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          done = {
            key = "done",
            label = "󰄬 done", -- nf-md-check_circle_outline
            hl_group = "CheckmateMetaDone",
            on_state = { "DONE" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          due = {
            key = "due",
            label = "󰃰 due", -- nf-md-calendar_clock
            hl_group = "CheckmateMetaDue",
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          priority = {
            key = "priority",
            label = "󰃙 priority", -- nf-md-flag_outline
            hl_group = "CheckmateMetaPriority",
            value = { type = "string" },
          },
        },

        -- ── Keymaps (all buffer-local in markdown files) ─────────────────
        keys = {
          -- Core toggles
          ["<leader>Tt"] = {
            rhs = "<cmd>Checkmate toggle<CR>",
            desc = "Toggle todo state",
            modes = { "n", "v" },
          },
          ["<leader>Tc"] = {
            rhs = "<cmd>Checkmate check<CR>",
            desc = "Mark DONE",
            modes = { "n", "v" },
          },
          ["<leader>Tu"] = {
            rhs = "<cmd>Checkmate uncheck<CR>",
            desc = "Mark TODO (unchecked)",
            modes = { "n", "v" },
          },

          -- State cycling
          ["<leader>T="] = {
            rhs = "<cmd>Checkmate cycle_next<CR>",
            desc = "Cycle to next state",
            modes = { "n", "v" },
          },
          ["<leader>T-"] = {
            rhs = "<cmd>Checkmate cycle_previous<CR>",
            desc = "Cycle to previous state",
            modes = { "n", "v" },
          },

          -- Create new todo
          ["<leader>Tn"] = {
            rhs = "<cmd>Checkmate create<CR>",
            desc = "New todo at same level",
            modes = { "n", "v" },
          },

          -- Quick metadata inserts
          ["<leader>Td"] = {
            rhs = "<cmd>Checkmate add_metadata due<CR>",
            desc = "Add @due date",
            modes = "n",
          },
          ["<leader>Tp"] = {
            rhs = "<cmd>Checkmate add_metadata priority<CR>",
            desc = "Add @priority",
            modes = "n",
          },

          -- Archive completed items
          ["<leader>Ta"] = {
            rhs = "<cmd>Checkmate archive<CR>",
            desc = "Archive completed todos",
            modes = "n",
          },

          -- Picker (search/filter todos in buffer)
          ["<leader>Ts"] = {
            rhs = "<cmd>Checkmate select_todo<CR>",
            desc = "Search todos (picker)",
            modes = "n",
          },
        },

        -- ── Picker ───────────────────────────────────────────────────────
        picker = {
          provider = "snacks", -- uses your existing snacks.nvim installation
          -- fallback: mini.pick → telescope (if snacks not available)
        },

        -- ── Archive section ──────────────────────────────────────────────
        archive = {
          heading = "## ✔ Archive",
          auto_fold = true,
        },

        -- ── Linting ──────────────────────────────────────────────────────
        -- You already have markdownlint-cli2 via nvim-lint – disable the built‑in linter.
        linter = {
          enabled = false,
        },
      }
    end,
  },
}
```

## `tools.lua`

```lua
return {
  -- ── Snacks Framework (System Control Dashboards, Terminals & Core Swaps) ────
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "",
            " ██████╗ ██╗   ██╗ █████╗ ██████╗ ██████╗ ██╗   ██╗███████╗██████╗ ███████╗ ██████╗ █████╗  ██████╗███████╗",
            "██╔═══╝ ██║   ██║██╔══██╗██╔══██╗██╔══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██╔══██╗██╔══██╗██╔════╝██╔════╝",
            "██║     ██║   ██║███████║██████╔╝██████╔╝██║   ██║█████╗  ██████╔╝█████╗  ██║  ██║███████║██║     ███████╗",
            "██║     ██║   ██║██╔══██║██╔══██╗██╔═══╝ ██║   ██║██╔══╝  ██╔══██╗██╔══╝  ██║  ██║██╔══██║██║     ╚════██║",
            "╚██████╗╚██████╔╝██║  ██║██║  ██║██║     ╚██████╔╝███████╗██║  ██║██║     ╚██████╔╝██║  ██║╚██████╗███████║",
            " ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝╚══════╝",
            "",
          }, "\n"),
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = function()
                Snacks.picker.files()
              end,
            },
            {
              icon = " ",
              key = "g",
              desc = "Find Text",
              action = function()
                Snacks.picker.grep()
              end,
            },
            {
              icon = " ",
              key = "r",
              desc = "Recent Files",
              action = function()
                Snacks.picker.recent()
              end,
            },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = function()
                Snacks.dashboard.open_config()
              end,
            },
            {
              icon = " ",
              key = "s",
              desc = "Restore Session",
              action = function()
                Snacks.session.restore()
              end,
            },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      terminal = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },

      -- ── NEW: Core Feature Modules ─────────────────────────────────────────────
      notifier = {
        enabled = true,
        timeout = 3000,
        style = "compact",
      },
      indent = {
        enabled = true,
        indent = { char = "│" },
        scope = { enabled = false },
      },
      scope = { enabled = true },
      picker = { enabled = true },
      input = { enabled = true },
      scroll = { enabled = true },
      animate = { enabled = true },
    },
    keys = {
      {
        "<leader>lg",
        function()
          Snacks.lazygit()
        end,
        desc = "Lazygit",
      },
      {
        "<leader>un",
        function()
          Snacks.notifier.hide()
        end,
        desc = "Dismiss All Notifications",
      },
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        mode = { "n", "t" },
        desc = "Toggle Terminal",
      },

      -- ── NEW: Notification History ────────────────────────────────────────────
      {
        "<leader>n",
        function()
          Snacks.notifier.show_history()
        end,
        desc = "Notification History",
      },

      -- ── NEW: Native Drop-In Picker Hotkeys ───────────────────────────────────
      {
        "<leader>ff",
        function()
          Snacks.picker.files()
        end,
        desc = "Find Files",
      },
      {
        "<leader>fg",
        function()
          Snacks.picker.grep()
        end,
        desc = "Live Grep",
      },
      {
        "<leader>fb",
        function()
          Snacks.picker.buffers()
        end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function()
          Snacks.picker.help()
        end,
        desc = "Help Tags",
      },
      {
        "<leader>fr",
        function()
          Snacks.picker.recent()
        end,
        desc = "Recent Files",
      },
    },
  },

  -- ── Neo-Tree Module (High-Speed Directory Structures) ─────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = { { "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", desc = "Toggle Explorer" } },
    opts = {
      window = { width = 35 },
      filesystem = { filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true } },
    },
  },

  -- ── Oil.nvim (Direct Text-Buffer File System Editor) ──────────────────────────
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil: Open parent directory" } },
    opts = { default_file_explorer = false },
  },

  -- ── Flash Jump (Multi-Window Motion Target Accelerators) ─────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
    },
  },
}
```

## `ui.lua`

```lua
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        -- override markdown rendering so that cmp and other plugins use Treesitter
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      routes = {
        {
          filter = { event = "msg_show", kind = "", find = "written" },
          opts = { skip = true },
        },
      },
      presets = {
        bottom_search = true,         -- use a classic bottom cmdline for search
        command_palette = true,       -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false,           -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = true,        -- add a border to hover docs and signature help
      },
    },
  },
}
```
