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
