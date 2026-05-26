- [ ] mini.pairs
- [ ] ts-comments.nvim
- [ ] lazydev.nvim
- [ ] MagicDuck/grug-far.nvim
- [ ] folke/flash.nvim
- [ ] which-key.nvim
- [ ] todo-comments.nvim
- [ ] peek.nvim

The following code is astrocommunity github project.

---

# confirm.nvim

```lua
{
  "stevearc/conform.nvim",
  dependencies = { "mason.nvim" },
  lazy = true,
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cF",
      function()
        require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
      end,
      mode = { "n", "x" },
      desc = "Format Injected Langs",
    },
  },
  init = function()
    -- Install the conform formatter on VeryLazy
    LazyVim.on_very_lazy(function()
      LazyVim.format.register({
        name = "conform.nvim",
        priority = 100,
        primary = true,
        format = function(buf)
          require("conform").format({ bufnr = buf })
        end,
        sources = function(buf)
          local ret = require("conform").list_formatters(buf)
          ---@param v conform.FormatterInfo
          return vim.tbl_map(function(v)
            return v.name
          end, ret)
        end,
      })
    end)
  end,
  opts = function()
    local plugin = require("lazy.core.config").plugins["conform.nvim"]
    if plugin.config ~= M.setup then
      LazyVim.error({
        "Don't set `plugin.config` for `conform.nvim`.\n",
        "This will break **LazyVim** formatting.\n",
        "Please refer to the docs at https://www.lazyvim.org/plugins/formatting",
      }, { title = "LazyVim" })
    end
    ---@type conform.setupOpts
    local opts = {
      default_format_opts = {
        timeout_ms = 3000,
        async = false, -- not recommended to change
        quiet = false, -- not recommended to change
        lsp_format = "fallback", -- not recommended to change
      },
      formatters_by_ft = {
        lua = { "stylua" },
        fish = { "fish_indent" },
        sh = { "shfmt" },
      },
      -- The options you set here will be merged with the builtin formatters.
      -- You can also define any custom formatters here.
      ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
      formatters = {
        injected = { options = { ignore_errors = true } },
        -- # Example of using dprint only when a dprint.json file is present
        -- dprint = {
        --   condition = function(ctx)
        --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
        --   end,
        -- },
        --
        -- # Example of using shfmt with extra args
        -- shfmt = {
        --   prepend_args = { "-i", "2", "-ci" },
        -- },
      },
    }
    return opts
  end,
  config = M.setup,
}
```

# nvim-lspconfig

```lua
{
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    { "mason-org/mason-lspconfig.nvim", config = function() end },
  },
  opts_extend = { "servers.*.keys" },
  opts = function()
    ---@class PluginLspOpts
    local ret = {
      -- options for vim.diagnostic.config()
      ---@type vim.diagnostic.Opts
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
          -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
          -- prefix = "icons",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = LazyVim.config.icons.diagnostics.Error,
            [vim.diagnostic.severity.WARN] = LazyVim.config.icons.diagnostics.Warn,
            [vim.diagnostic.severity.HINT] = LazyVim.config.icons.diagnostics.Hint,
            [vim.diagnostic.severity.INFO] = LazyVim.config.icons.diagnostics.Info,
          },
        },
      },
      -- Enable this to enable the builtin LSP inlay hints on Neovim.
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,
        exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
      },
      -- Enable this to enable the builtin LSP code lenses on Neovim.
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },
      -- Enable this to enable the builtin LSP folding on Neovim.
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the folds.
      folds = {
        enabled = true,
      },
      -- options for vim.lsp.buf.format
      -- `bufnr` and `filter` is handled by the LazyVim formatter,
      -- but can be also overridden when specified
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
      -- LSP Server Settings
      -- Sets the default configuration for an LSP client (or all clients if the special name "*" is used).
      ---@alias lazyvim.lsp.Config vim.lsp.Config|{mason?:boolean, enabled?:boolean, keys?:LazyKeysLspSpec[]}
      ---@type table<string, lazyvim.lsp.Config|boolean>
      servers = {
        -- configuration for all lsp servers
        ["*"] = {
          capabilities = {
            workspace = {
              fileOperations = {
                didRename = true,
                willRename = true,
              },
            },
          },
          -- stylua: ignore
          keys = {
            { "<leader>cl", function() Snacks.picker.lsp_config() end, desc = "Lsp Info" },
            { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
            { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
            { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
            { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
            { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
            { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
            { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
            { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" }, has = "codeAction" },
            { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" }, has = "codeLens" },
            { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
            { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
            { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
            { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
            { "]]", function() Snacks.words.jump(vim.v.count1) end, has = "documentHighlight",
              desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "[[", function() Snacks.words.jump(-vim.v.count1) end, has = "documentHighlight",
              desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, has = "documentHighlight",
              desc = "Next Reference", enabled = function() return Snacks.words.is_enabled() end },
            { "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, has = "documentHighlight",
              desc = "Prev Reference", enabled = function() return Snacks.words.is_enabled() end },
            {
              "<leader>co",
              LazyVim.lsp.action["source.organizeImports"],
              desc = "Organize Imports",
              has = "codeAction",
              enabled = function(buf)
                local code_actions = vim.tbl_filter(function(action)
                  return action:find("^source%.organizeImports%.?$")
                end, LazyVim.lsp.code_actions({ bufnr = buf }))
                return #code_actions > 0
              end
            },
          },
        },
        stylua = { enabled = false },
        lua_ls = {
          -- mason = false, -- set to false if you don't want this server to be installed with mason
          -- Use this to add any additional keymaps
          -- for specific lsp servers
          -- ---@type LazyKeysSpec[]
          -- keys = {},
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              codeLens = {
                enable = true,
              },
              completion = {
                callSnippet = "Replace",
              },
              doc = {
                privateName = { "^_" },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
            },
          },
        },
      },
      -- you can do any additional lsp server setup here
      -- return true if you don't want this server to be setup with lspconfig
      ---@type table<string, fun(server:string, opts: vim.lsp.Config):boolean?>
      setup = {
        -- example to setup with typescript.nvim
        -- tsserver = function(_, opts)
        --   require("typescript").setup({ server = opts })
        --   return true
        -- end,
        -- Specify * to use this function as a fallback for any server
        -- ["*"] = function(server, opts) end,
      },
    }
    return ret
  end,
  ---@param opts PluginLspOpts
  config = function(_, opts)
    -- setup autoformat
    LazyVim.format.register(LazyVim.lsp.formatter())

    -- setup keymaps
    local names = vim.tbl_keys(opts.servers) ---@type string[]
    table.sort(names)
    for _, server in ipairs(names) do
      local server_opts = opts.servers[server]
      if type(server_opts) == "table" and server_opts.keys then
        require("lazyvim.plugins.lsp.keymaps").set({ name = server ~= "*" and server or nil }, server_opts.keys)
      end
    end

    -- inlay hints
    if opts.inlay_hints.enabled then
      Snacks.util.lsp.on({ method = "textDocument/inlayHint" }, function(buffer)
        if
          vim.api.nvim_buf_is_valid(buffer)
          and vim.bo[buffer].buftype == ""
          and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
        then
          vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
        end
      end)
    end

    -- folds
    if opts.folds.enabled then
      Snacks.util.lsp.on({ method = "textDocument/foldingRange" }, function()
        if LazyVim.set_default("foldmethod", "expr") then
          LazyVim.set_default("foldexpr", "v:lua.vim.lsp.foldexpr()")
        end
      end)
    end

    -- code lens
    if opts.codelens.enabled and vim.lsp.codelens then
      Snacks.util.lsp.on({ method = "textDocument/codeLens" }, function(buffer)
        vim.lsp.codelens.refresh()
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
          buffer = buffer,
          callback = vim.lsp.codelens.refresh,
        })
      end)
    end

    -- diagnostics
    if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
      opts.diagnostics.virtual_text.prefix = function(diagnostic)
        local icons = LazyVim.config.icons.diagnostics
        for d, icon in pairs(icons) do
          if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
            return icon
          end
        end
        return "●"
      end
    end
    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

    if opts.capabilities then
      LazyVim.deprecate("lsp-config.opts.capabilities", "Use lsp-config.opts.servers['*'].capabilities instead")
      opts.servers["*"] = vim.tbl_deep_extend("force", opts.servers["*"] or {}, {
        capabilities = opts.capabilities,
      })
    end

    if opts.servers["*"] then
      vim.lsp.config("*", opts.servers["*"])
    end

    -- get all the servers that are available through mason-lspconfig
    local have_mason = LazyVim.has("mason-lspconfig.nvim")
    local mason_all = have_mason
        and vim.tbl_keys(require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package)
      or {} --[[ @as string[] ]]
    local mason_exclude = {} ---@type string[]

    ---@return boolean? exclude automatic setup
    local function configure(server)
      if server == "*" then
        return false
      end
      local sopts = opts.servers[server]
      sopts = sopts == true and {} or (not sopts) and { enabled = false } or sopts --[[@as lazyvim.lsp.Config]]

      if sopts.enabled == false then
        mason_exclude[#mason_exclude + 1] = server
        return
      end

      local use_mason = sopts.mason ~= false and vim.tbl_contains(mason_all, server)
      local setup = opts.setup[server] or opts.setup["*"]
      if setup and setup(server, sopts) then
        mason_exclude[#mason_exclude + 1] = server
      else
        vim.lsp.config(server, sopts) -- configure the server
        if not use_mason then
          vim.lsp.enable(server)
        end
      end
      return use_mason
    end

    local install = vim.tbl_filter(configure, vim.tbl_keys(opts.servers))
    if have_mason then
      require("mason-lspconfig").setup({
        ensure_installed = vim.list_extend(install, LazyVim.opts("mason-lspconfig.nvim").ensure_installed or {}),
        automatic_enable = { exclude = mason_exclude },
      })
    end
  end,
}

```

# vimtex

```lua
return {
  "lervag/vimtex",
  lazy = false,
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          vimtex_mapping_descriptions = {
            {
              event = "FileType",
              desc = "Set up VimTex Which-Key descriptions",
              pattern = "tex",
              callback = function(event)
                local wk_avail, wk = pcall(require, "which-key")
                if not wk_avail then return end
                wk.add {
                  buffer = event.buf,
                  {
                    mode = "n",
                    { "<localleader>l", group = "VimTeX" },
                    { "<localleader>la", desc = "Show Context Menu" },
                    { "<localleader>lC", desc = "Full Clean" },
                    { "<localleader>lc", desc = "Clean" },
                    { "<localleader>le", desc = "Show Errors" },
                    { "<localleader>lG", desc = "Show Status for All" },
                    { "<localleader>lg", desc = "Show Status" },
                    { "<localleader>li", desc = "Show Info" },
                    { "<localleader>lI", desc = "Show Full Info" },
                    { "<localleader>lk", desc = "Stop VimTeX" },
                    { "<localleader>lK", desc = "Stop All VimTeX" },
                    { "<localleader>lL", desc = "Compile Selection" },
                    { "<localleader>ll", desc = "Compile" },
                    { "<localleader>lm", desc = "Show Imaps" },
                    { "<localleader>lo", desc = "Show Compiler Output" },
                    { "<localleader>lq", desc = "Show VimTeX Log" },
                    { "<localleader>ls", desc = "Toggle Main" },
                    { "<localleader>lt", desc = "Open Table of Contents" },
                    { "<localleader>lT", desc = "Toggle Table of Contents" },
                    { "<localleader>lv", desc = "View Compiled Document" },
                    { "<localleader>lX", desc = "Reload VimTeX State" },
                    { "<localleader>lx", desc = "Reload VimTeX" },
                    { "ts", group = "VimTeX Toggles & Cycles" },
                    { "ts$", desc = "Cycle inline, display & numbered equation" },
                    { "tsc", desc = "Toggle star of command" },
                    { "tsd", desc = "Cycle (), \\left(\\right) [,...]" },
                    { "tsD", desc = "Reverse Cycle (), \\left(\\right) [, ...]" },
                    { "tse", desc = "Toggle star of environment" },
                    { "tsf", desc = "Toggle a/b vs \\frac{a}{b}" },
                    { "tsb", desc = "Toggle line break" },
                    { "tss", desc = "Toggle starred environment" },
                    { "[/", desc = "Previous start of a LaTeX comment" },
                    { "[*", desc = "Previous end of a LaTeX comment" },
                    { "[[", desc = "Previous beginning of a section" },
                    { "[]", desc = "Previous end of a section" },
                    { "[m", desc = "Previous \\begin" },
                    { "[M", desc = "Previous \\end" },
                    { "[n", desc = "Previous start of a math zone" },
                    { "[N", desc = "Previous end of a math zone" },
                    { "[r", desc = "Previous \\begin{frame}" },
                    { "[R", desc = "Previous \\end{frame}" },
                    { "]/", desc = "Next start of a LaTeX comment %" },
                    { "]*", desc = "Next end of a LaTeX comment %" },
                    { "][", desc = "Next beginning of a section" },
                    { "]]", desc = "Next end of a section" },
                    { "]m", desc = "Next \\begin" },
                    { "]M", desc = "Next \\end" },
                    { "]n", desc = "Next start of a math zone" },
                    { "]N", desc = "Next end of a math zone" },
                    { "]r", desc = "Next \\begin{frame}" },
                    { "]R", desc = "Next \\end{frame}" },
                    { "csc", desc = "Change surrounding command" },
                    { "cse", desc = "Change surrounding environment" },
                    { "cs$", desc = "Change surrounding math zone" },
                    { "csd", desc = "Change surrounding delimiter" },
                    { "dsc", desc = "Delete surrounding command" },
                    { "dse", desc = "Delete surrounding environment" },
                    { "ds$", desc = "Delete surrounding math zone" },
                    { "dsd", desc = "Delete surrounding delimiter" },
                  },
                  {
                    mode = "o",
                    { "ic", desc = "LaTeX Command" },
                    { "ac", desc = "LaTeX Command" },
                    { "id", desc = "LaTeX Math Delimiter" },
                    { "ad", desc = "LaTeX Math Delimiter" },
                    { "ie", desc = "LaTeX Environment" },
                    { "ae", desc = "LaTeX Environment" },
                    { "i$", desc = "LaTeX Math Zone" },
                    { "a$", desc = "LaTeX Math Zone" },
                    { "iP", desc = "LaTeX Section, Paragraph, ..." },
                    { "aP", desc = "LaTeX Section, Paragraph, ..." },
                    { "im", desc = "LaTeX Item" },
                    { "am", desc = "LaTeX Item" },
                  },
                }
              end,
            },
          },
        },
      },
    },
    {
      "nvim-treesitter/nvim-treesitter",
      opts = function(_, opts)
        opts.highlight = opts.highlight or {}
        if type(opts.highlight.disable) == "table" then
          vim.list_extend(opts.highlight.disable, { "latex" })
        else
          opts.highlight.disable = { "latex" }
        end
      end,
    },
  },
}

```
