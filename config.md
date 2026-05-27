# QuantumVim Configuration

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
        "netrwPlugin",
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

## `lua/core/autocmds.lua`

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

### `keymaps.lua.txt`

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

### `options.lua.txt`

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
