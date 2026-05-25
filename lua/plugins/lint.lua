return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      -- Mutate only the args property to preserve the built-in parser function
      lint.linters.selene.args = {
        "--display-style",
        "quiet",
        "--config",
        vim.fn.expand("~/.config/nvim/selene.toml"),
      }

      lint.linters_by_ft = {
        lua = { "selene" },
        python = { "ruff" },
        markdown = {},
        yaml = { "yamllint" },
        json = { "jsonlint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
