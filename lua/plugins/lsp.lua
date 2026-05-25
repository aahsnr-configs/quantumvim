return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = {
          lua = { inherit_defaults = true, "lazydev" },
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, func, desc, opts)
            opts = opts or {}
            opts.buffer = bufnr
            opts.desc = "LSP: " .. desc
            vim.keymap.set("n", keys, func, opts)
          end
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gr", vim.lsp.buf.references, "Go to References")
          map("gI", vim.lsp.buf.implementation, "Go to Implementation")
          map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
          map("<leader>ds", vim.lsp.buf.document_symbol, "Document Symbols")
          map("<leader>ws", vim.lsp.buf.workspace_symbol, "Workspace Symbols")
          map("<leader>rn", function()
            return ":" .. vim.v.count1 .. "IncRename "
          end, "Rename Symbol", { expr = true })
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("K", vim.lsp.buf.hover, "Hover Documentation")

          if vim.bo[bufnr].filetype == "markdown" then
            vim.diagnostic.enable(false, { bufnr = bufnr })
          end
        end,
      })

      -- Modern diagnostic configuration (Neovim 0.12 best practices)
      vim.diagnostic.config({
        virtual_text = false, -- Never describe the error/warning inline
        signs = false, -- Remove any shorthand on the left signcolumn
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })
      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = { typeCheckingMode = "standard" },
          },
        },
      })
      vim.lsp.config("marksman", {
        settings = {
          diagnostics = { enable = false },
          completion = { enable = true },
        },
      })
    end,
  },
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    config = true,
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = { window = { winblend = 0 } },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { use_diagnostic_signs = false },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<cr>", desc = "LSP (Trouble)" },

      -- Diagnostic Inspection and Filtering Keybindings
      {
        "<leader>ce",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.ERROR })
        end,
        desc = "Diagnostics: Describe Error at Cursor",
      },
      {
        "<leader>xe",
        "<cmd>Trouble diagnostics toggle filter.severity=ERROR<cr>",
        desc = "Diagnostics: Toggle All Errors",
      },
      {
        "<leader>cw",
        function()
          vim.diagnostic.open_float({ scope = "cursor", severity = vim.diagnostic.severity.WARN })
        end,
        desc = "Diagnostics: Describe Warning at Cursor",
      },
      {
        "<leader>xw",
        "<cmd>Trouble diagnostics toggle filter.severity=WARN<cr>",
        desc = "Diagnostics: Toggle All Warnings",
      },
      {
        "<leader>xd",
        function()
          vim.diagnostic.enable(not vim.diagnostic.is_enabled())
        end,
        desc = "Diagnostics: Toggle Diagnostics On/Off",
      },
    },
  },
}
