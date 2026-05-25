return {
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
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          prompt_prefix = " ",
          selection_caret = " ",
          path_display = { "tail" },
          file_ignore_patterns = { "node_modules", ".git/" },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("yank_history")
    end,
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
    end,
  },

  { "kylechui/nvim-surround", event = "BufReadPost", version = "*", opts = {} },

  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "gco", desc = "Comment: add line below" },
        { "gcO", desc = "Comment: add line above" },
        { "gcA", desc = "Comment: add at end of line" },
      },
    },
  },
  {
    dir = vim.fn.stdpath("config"),
    name = "comment-extras",
    event = "VeryLazy",
    config = function()
      vim.keymap.set("n", "gco", 'o<Esc>0"_Dgcc$', { desc = "Comment: open line below", remap = true, silent = true })
      vim.keymap.set("n", "gcO", 'O<Esc>0"_Dgcc$', { desc = "Comment: open line above", remap = true, silent = true })
      vim.keymap.set("n", "gcA", "A<Space><Esc>gcc$", { desc = "Comment: append at EOL", remap = true, silent = true })
    end,
  },

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

  -- ── TODO Comments ──────────────────────────────────────────────────────
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Find Todo" },
    },
  },

  -- ── Mini.ai (Advanced Textobjects) ────────────────────────────────────
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {},
  },
}
