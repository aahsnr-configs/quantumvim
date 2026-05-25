return {
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>cf", function() require("conform").format { async = true } end, desc = "Format buffer" },
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
      },
      format_on_save = function(bufnr)
        if not vim.g.autoformat then return end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}

