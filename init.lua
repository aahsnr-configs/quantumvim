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
