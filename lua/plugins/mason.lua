return {
  {
    "williamboman/mason.nvim",
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
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
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
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
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
}
