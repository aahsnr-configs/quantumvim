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
