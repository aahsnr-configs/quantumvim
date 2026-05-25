vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
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

require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.mason" },
  { import = "plugins.lsp" },
  { import = "plugins.formatter" },
  { import = "plugins.lint" },
  { import = "plugins.completion" },
  { import = "plugins.git" },
  { import = "plugins.markdown" },
  { import = "plugins.tools" },
}, {
  checker = { enabled = true },
  change_detection = { notify = true },
  install = {
    -- Use the colorscheme while lazy installs on first launch
    colorscheme = { "catppuccin", "habamax" },
  },
  performance = {
    rtp = {
      -- Disable unused built-in plugins for a leaner runtime
      disabled_plugins = {
        "gzip",
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

require("core.options")
require("core.keymaps")
require("core.autocmds")
