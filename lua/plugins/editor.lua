return {
  -- ── Tree-sitter Framework (Asynchronous Grammar Compilation) ────────────────
  {
    "romus204/tree-sitter-manager.nvim",
    event = "VeryLazy",
    main = "tree-sitter-manager",
    opts = {
      ensure_installed = {
        "python",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "json",
        "yaml",
        "toml",
        "bash",
        "go",
        "rust",
        "regex",
        "lua",
        "markdown",
        "markdown_inline",
      },
    },
  },

  -- ── TS-Autotag (Automated Dynamic Tag Conversions) ──────────────────────────
  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "xml",
          "markdown",
        },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    optional = true,
  -- stylua: ignore
  keys = {
    { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
    { "<leader>sT", function () Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
  },
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ── mini.pairs ────────────────────────────────────────────────────────────────
  -- Autopairs plugin from the mini.nvim suite.
  -- https://github.com/nvim-mini/mini.pairs
  --
  -- Design contract with markdown.lua:
  --   • mini.pairs owns all GLOBAL single-character pair mappings ((, [, {, ", ', `).
  --   • markdown.lua owns multi-character markdown pairs (**→****, __→____) via
  --     raw vim.keymap.set() — mini.pairs cannot handle multi-char open/close symbols.
  --   • markdown.lua adds one buffer-local mini.pairs mapping for $ (inline LaTeX)
  --     via MiniPairs.map_buf() in its setup_markdown_buffer() function.
  -- ──────────────────────────────────────────────────────────────────────────────

  {
    -- Install as a standalone mini plugin (not the full mini.nvim suite).
    -- If you already have "nvim-mini/mini.nvim" in your config, replace this
    -- entry with { import = "mini.pairs" } or just add the setup call there.
    "nvim-mini/mini.pairs",
    event = "InsertEnter", -- load on first keystroke in Insert mode

    config = function()
      require("mini.pairs").setup({
        -- ── Mode scope ────────────────────────────────────────────────
        -- Insert mode only. Command mode is useful but can feel surprising
        -- when typing ex-commands. Terminal mode conflicts with REPL
        -- autopairing (ipython, radian, etc.).
        modes = {
          insert = true,
          command = false,
          terminal = false,
        },

        -- ── Global mappings ───────────────────────────────────────────
        -- Each value is a pair_info table consumed by MiniPairs.map().
        -- Supply `false` to disable a particular key entirely.
        --
        -- neigh_pattern is a 2-char Lua pattern matched against the
        -- character to the LEFT and RIGHT of the cursor.
        --   '^[^\\]'   → don't complete after a backslash (escape)
        --   '^[^%a\\]' → don't complete after a letter or backslash
        --                (avoids pairing ' inside words like don't)
        mappings = {
          -- ── Asymmetric brackets ───────────────────────────────────
          ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
          ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
          ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

          [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
          ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
          ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },

          -- ── Symmetric / quote-style pairs ─────────────────────────
          -- register.cr = false: don't expand these into a blank line on <CR>,
          -- because quotes rarely open a block the way brackets do.
          ['"'] = {
            action = "closeopen",
            pair = '""',
            neigh_pattern = "^[^\\]", -- no pair after backslash
            register = { cr = false },
          },
          ["'"] = {
            action = "closeopen",
            pair = "''",
            neigh_pattern = "^[^%a\\]", -- no pair after a letter or backslash
            register = { cr = false }, -- prevents pairing inside contractions
          },
          ["`"] = {
            action = "closeopen",
            pair = "``",
            neigh_pattern = "^[^\\]",
            register = { cr = false },
          },

          -- ── Intentionally not mapped here ─────────────────────────
          -- "*" and "_"  — markdown.lua handles "**" bold and "__" italic
          --                with dedicated keymaps; adding * / _ as
          --                closeopen here would break them.
          -- "$"          — markdown.lua adds this per-buffer for markdown
          --                files only (inline LaTeX), so it is absent here
          --                to avoid inserting paired $$ in every filetype.
        },
      })
    end,
  },
}
