return {
  -- ==========================================================================
  -- 1. MASON PACKAGE MANAGEMENT & AUTOMATED TOOLING
  -- ==========================================================================
  {
    "mason-org/mason.nvim",
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
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
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
        "texlab",
      },
      -- automatic_enable = true is the default in v2; no explicit flag needed.
      -- Installed servers are automatically enabled via vim.lsp.enable().
      -- NOTE: automatic_installation was removed in v2. Use ensure_installed instead.
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
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
        "latexindent",
        "chktex",
      },
      auto_update = true,
      run_on_start = true,
    },
  },

  -- ==========================================================================
  -- 2. COMPLETION ENGINE MODULE (BLINK.CMP & VISUAL EXTENSIONS)
  -- ==========================================================================
  {
    "xzbdmw/colorful-menu.nvim",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- blink.lib removed: it is a V2-only dependency, not used in V1
      "rafamadriz/friendly-snippets",
      "xzbdmw/colorful-menu.nvim",
      { "saghen/blink.compat", opts = {} },
      "kdheepak/cmp-latex-symbols",
      "moyiz/blink-emoji.nvim",
      "mikavilpas/blink-ripgrep.nvim",
    },
    build = "cargo build --release",
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      enabled = function()
        return vim.bo.buftype ~= "prompt" and vim.b.completion ~= false
      end,

      cmdline = { enabled = true },

      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
        ["<C-u>"] = { "scroll_signature_up", "fallback" },
        ["<C-d>"] = { "scroll_signature_down", "fallback" },
      },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        keyword = {
          range = "full",
        },

        accept = { auto_brackets = { enabled = false } },

        list = {
          selection = {
            preselect = function(ctx)
              return vim.bo.filetype ~= "markdown"
            end,
            auto_insert = true,
          },
        },

        ghost_text = { enabled = true },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },

        menu = {
          border = "none",
          draw = {
            columns = {
              { "kind_icon" },
              { "label",    gap = 1 },
            },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },

      signature = { enabled = true },

      fuzzy = {
        implementation = "prefer_rust",
        prebuilt_binaries = { download = false }, -- Strictly rely on native compilation architecture
        sorts = { "score", "sort_text", "kind", "label" },
      },

      snippets = { preset = "default" },

      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          -- Explicitly list all sources for lua; inherit_defaults is a V2 feature
          lua = { "lsp", "path", "snippets", "buffer", "lazydev" },
          markdown = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },
          tex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" },      -- LaTeX Integrated Context Mining
          plaintex = { "lsp", "path", "snippets", "buffer", "latex_symbols", "emoji", "ripgrep" }, -- LaTeX Integrated Context Mining
        },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
          latex_symbols = {
            name = "latex_symbols",
            module = "blink.compat.source",
            score_offset = 2,
          },
          emoji = {
            name = "Emoji",
            module = "blink-emoji",
            score_offset = 1,
          },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            score_offset = 0,
          },
        },
      },
    },
  },

  -- ==========================================================================
  -- 3. CORE LANGUAGE RUNTIMES & INTERFACES (LSP)
  -- ==========================================================================
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
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "j-hui/fidget.nvim",
    },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, func, desc, extra_opts)
            extra_opts = extra_opts or {}
            local mode = extra_opts.mode or "n"
            extra_opts.mode = nil
            extra_opts.buffer = bufnr
            extra_opts.desc = "LSP: " .. desc
            vim.keymap.set(mode, keys, func, extra_opts)
          end

          -- ── Snacks Asynchronous Picker Mappings ─────────────────────────
          map("gd", function()
            Snacks.picker.lsp_definitions()
          end, "Go to Definition")
          map("gr", function()
            Snacks.picker.lsp_references()
          end, "Go to References")
          map("gI", function()
            Snacks.picker.lsp_implementations()
          end, "Go to Implementation")

          -- Standard Core Operational Hooks
          map("<leader>cr", vim.lsp.buf.rename, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { mode = { "n", "v" } })
          map("K", vim.lsp.buf.hover, "Hover Documentation")
        end,
      })

      -- Set blink.cmp capabilities globally for all servers in one call.
      -- vim.lsp.config('*', ...) merges into every server's config.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- Per-server settings. nvim-lspconfig still provides the default
      -- root_dir, filetypes, and cmd values; we only override what differs.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { checkThirdParty = false },
            telemetry = { enabled = false },
          },
        },
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
              typeCheckingMode = "basic",
            },
          },
        },
      })

      vim.lsp.config("marksman", {
        filetypes = { "markdown", "md" },
      })

      vim.lsp.config("html", {
        filetypes = { "html", "xhtml" },
        init_options = { provideFormatter = true },
      })

      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash" },
        settings = { bashIde = { globPattern = "*@(.sh|.inc|.bash|.command)" } },
      })

      vim.lsp.config("texlab", { -- LaTeX Integrated LSP Server Config
        settings = {
          texlab = {
            build = {
              executable = "latexmk",
              args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
              onSave = true,
            },
            forwardSearch = {
              executable = "zathura",
              args = { "--synctex-forward", "%l:1:%c", "%p" },
            },
            chktex = { onOpenAndSave = true, onType = false },
            diagnosticsDelay = 300,
          },
        },
      })

      -- ts_ls, cssls, jsonls, gopls, rust_analyzer use nvim-lspconfig defaults;
      -- only capabilities (set globally above) are needed.
    end,
  },
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP (Trouble)" },
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
        desc = "Diagnostics: Global Toggle On/Off",
      },
    },
  },

  -- ==========================================================================
  -- 4. WORKSPACE AUTOMATED FORMATTING LIFECYCLES (CONFORM)
  -- ==========================================================================
  {
    "stevearc/conform.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true })
        end,
        desc = "Format buffer",
      },
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
        tex = { "latexindent" },
        plaintex = { "latexindent" },
      },
      format_on_save = function(bufnr)
        if not vim.g.autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },

  -- ==========================================================================
  -- 5. ASYNCHRONOUS WORKSPACE LINTING OPERATIONS (NVIM-LINT)
  -- ==========================================================================
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require("lint")

      lint.linters.selene = lint.linters.selene or {}
      lint.linters.selene.args = {
        "--display-style",
        "quiet",
        "--config",
        vim.fn.expand("~/.config/nvim/selene.toml"),
      }

      lint.linters_by_ft = {
        lua = { "selene" },
        python = { "ruff" },
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
        tex = { "chktex" },
        plaintex = { "chktex" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
