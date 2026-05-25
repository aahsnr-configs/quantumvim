-- ── UI ────────────────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.numberwidth = 3
vim.opt.pumheight = 10
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.conceallevel = 0
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.fillchars = { eob = " " }

-- ── Editing ────────────────────────────────────────────────────────────────
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.virtualedit = "block"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- ── Search ─────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"

-- ── Windows & Splits ───────────────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── Persistence ────────────────────────────────────────────────────────────
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath "data" .. "/undo"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- ── Performance & Behaviour ────────────────────────────────────────────────
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.autoread = true
vim.opt.fileencoding = "utf-8"
vim.opt.spell = false
vim.opt.spelllang = { "en_us" }
vim.opt.isfname:append "@-@"

-- ── Silence optional provider warnings ─────────────────────────────────────
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
