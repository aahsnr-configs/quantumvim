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
