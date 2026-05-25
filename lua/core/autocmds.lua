vim.g.autoformat = true -- global toggle, respected by conform.nvim

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local core_group = augroup("CoreAutocmds", { clear = true })

-- 1. Brief highlight of yanked text
autocmd("TextYankPost", {
  group = core_group,
  desc = "Highlight yanked text for 200 ms",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- 2. Strip trailing whitespace before writing the file
autocmd("BufWritePre", {
  group = core_group,
  pattern = "*",
  desc = "Remove trailing whitespace on save",
  callback = function(args)
    if not vim.bo[args.buf].modifiable then
      return
    end
    local view = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- 3. Return to the last cursor position when opening a file
autocmd("BufReadPost", {
  group = core_group,
  desc = "Restore last cursor position (skips git commit messages)",
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

-- 4. Prevent automatic insertion of comment leaders on new lines
autocmd("FileType", {
  group = core_group,
  pattern = "*",
  desc = "Remove c, r, o from formatoptions to disable comment continuation",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- Keymap to toggle autoformat on/off
vim.keymap.set("n", "<leader>tf", function()
  vim.g.autoformat = not vim.g.autoformat
  local state = vim.g.autoformat and "enabled" or "disabled"
  vim.notify("Format on save: " .. state, vim.log.levels.INFO, { title = "Formatting", timeout = 2000 })
end, { desc = "Toggle format on save" })
