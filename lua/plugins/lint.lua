return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      lint.linters.selene = {
        cmd = "selene",
        stdin = false,
        args = {
          "--display-style",
          "quiet",
          "--config",
          vim.fn.expand("~/.config/nvim/selene.toml"),
        },
        append_fname = true,
        stream = "stderr",
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
