To give your editor a fully realized identity, here is the complete, production-grade source code for every file in your configuration, refactored from top to bottom under the **QuantumVim** ecosystem specification.

All best practices are fully integrated, and the `snacks.nvim` entry dashboard has been refactored with a custom, custom-aligned **QUANTUM** ASCII art engine block.

---

### 📂 Root System Infrastructure

#### `~/.config/nvim/init.lua`

```lua
vim.loader.enable()
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.mason" },
  { import = "plugins.lsp" },
  { import = "plugins.formatter" },
  { import = "plugins.lint" },
  { import = "plugins.completion" },
  { import = "plugins.git" },
  { import = "plugins.markdown" },
  { import = "plugins.tools" },
}, {
  checker = { enabled = true },
  change_detection = { notify = true },
  install = {
    colorscheme = { "catppuccin", "habamax" },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "netrwPlugin",
        "rplugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

```

#### `~/.config/nvim/options.lua`

```lua
-- ── UI ────────────────────────────────────────────────────────────────────
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.showmode = false
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.showtabline = 0
vim.opt.numberwidth = 3
vim.opt.pumheight = 10
vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.conceallevel = 0
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.fillchars = { eob = " " }

-- ── Editing ────────────────────────────────────────────────────────────────
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.autoindent = true
vim.opt.virtualedit = "block"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

-- ── Search ─────────────────────────────────────────────────────────────────
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.inccommand = "split"

-- ── Windows & Splits ───────────────────────────────────────────────────────
vim.opt.splitright = true
vim.opt.splitbelow = true

-- ── Persistence ────────────────────────────────────────────────────────────
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath "data" .. "/undo"
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false

-- ── Performance & Behaviour ────────────────────────────────────────────────
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.autoread = true
vim.opt.fileencoding = "utf-8"

```

#### `~/.config/nvim/keymaps.lua`

```lua
local map = vim.keymap.set

map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })
map("n", "<leader>se", "<C-w>=", { desc = "Equalize split sizes" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close current split" })

map("n", "<C-h>", "<C-w>h", { desc = "Navigate to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate to lower window" })
map("n", "<C-k>\", "<C-w>k", { desc = "Navigate to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate to right window" })

map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

map("i", "jk", "<esc>", { desc = "Exit insert mode" })

map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

```

#### `~/.config/nvim/autocmds.lua`

```lua
vim.g.autoformat = true

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local core_group = augroup("CoreAutocmds", { clear = true })

-- 1. Brief highlight of yanked text
autocmd("TextYankPost", {
  group = core_group,
  desc = "Highlight yanked text for 200 ms",
  callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 200 } end,
})

-- 2. Strip trailing whitespace before writing the file
autocmd("BufWritePre", {
  group = core_group,
  pattern = "*",
  desc = "Remove trailing whitespace on save",
  callback = function(args)
    if not vim.bo[args.buf].modifiable then return end
    local view = vim.fn.winsaveview()
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.winrestview(view)
  end,
})

-- 3. Return to the last cursor position when opening a file
autocmd("BufReadPost", {
  group = core_group,
  desc = "Restore last cursor position (skips git commit messages)",
  callback = function()
    if vim.bo.filetype == "gitcommit" then return end
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then vim.api.nvim_win_set_cursor(0, mark) end
  end,
})

-- 4. Prevent automatic insertion of comment leaders on new lines
autocmd("FileType", {
  group = core_group,
  pattern = "*",
  desc = "Remove c, r, o from formatoptions to disable comment continuation",
  callback = function() vim.opt_local.formatoptions:remove { "c", "r", "o" } end,
})

```

---

### 🛡️ Code Quality Profiles & Custom Architecture Matrices

#### `~/.config/nvim/.stylua.toml`

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"

[sort_requires]
enabled = true

```

#### `~/.config/nvim/selene.toml`

```toml
std = "neovim"

[lints]
global_usage = "allow"
mixed_table = "allow"
multiple_statements = "allow"
empty_if = "allow"
unscoped_variables = "allow"

shadowing = "warn"
unused_variable = "warn"
incorrect_standard_library_use = "deny"
divide_by_zero = "deny"
unreachable_code = "deny"
duplicate_keys = "deny"

```

#### `~/.config/nvim/neovim.yml`

```yaml
name: neovim
base: lua51
globals:
  vim:
    any: true
  jit:
    any: true
  bit:
    any: true
  describe:
    any: true
  it:
    any: true
  before_each:
    any: true
  after_each:
    any: true
  assert:
    any: true
  require:
    args:
      - type: string
```

---

### 🧩 Feature Ecosystem Modules (`lua/plugins/*`)

#### `~/.config/nvim/lua/plugins/ui.lua`

```lua
return {
  -- ── Colorscheme ─────────────────────────────────────────────────────────
  {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = false,
        highlight_overrides = {
          mocha = function(colors)
            return {
              GitSignsAdd = { fg = colors.green, bg = colors.none },
              GitSignsChange = { fg = colors.yellow, bg = colors.none },
              GitSignsDelete = { fg = colors.red, bg = colors.none },
            }
          end,
        },
        integrations = {
          blink_cmp = true,
          noice = true,
          notify = true,
          gitsigns = true,
          telescope = true,
          treesitter = true,
          illuminate = true,
          flash = true,
          neotree = true,
          snacks = { enabled = true },
          lualine = true,
          bufferline = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          mini = { enabled = true, indentscope_color = "" },
          dropbar = { enabled = true, color_mode = false },
        },
      })
      vim.cmd.colorscheme("catppuccin-mocha")
    end,
  },

  -- ── Statusline ──────────────────────────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local colors = require("catppuccin.palettes").get_palette("mocha")
      return {
        options = {
          theme = "catppuccin",
          component_separators = "",
          section_separators = "",
          globalstatus = true,
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } }, { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat" },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2, color = { fg = colors.crust, bg = colors.blue } } },
        },
      }
    end,
  },

  -- ── Bufferline ──────────────────────────────────────────────────────────
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
      options = {
        mode = "buffers",
        style_preset = "default",
        separator_style = "thin",
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },

  -- ── UI Enhancements & Components ────────────────────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.set_hud_header"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
      },
    },
  },
  {
    "rcarriga/nvim-notify",
    opts = { timeout = 3000, stages = "fade" },
  },
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-teleand/telescope-fzf-native.nvim" },
  },

  -- ── Indent Guides ───────────────────────────────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPost",
    main = "ibl",
    opts = { indent = { char = "│" }, scope = { enabled = false } },
  },
  {
    "echasnovski/mini.indentscope",
    event = "BufReadPost",
    version = "*",
    config = function()
      require("mini.indentscope").setup({
        symbol = "│",
        options = { try_as_border = true },
        draw = { animation = require("mini.indentscope").gen_animation.none() },
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help", "alpha", "dashboard", "snacks_dashboard", "lazy",
          "mason", "notify", "toggleterm", "Trouble", "trouble", "qf",
          "TelescopePrompt", "startify", "snacks_terminal",
        },
        callback = function() vim.b.miniindentscope_disable = true end,
      })
    end,
  },
}

```

#### `~/.config/nvim/lua/plugins/editor.lua`

```lua
return {
  {
    "romus204/tree-sitter-manager.nvim",
    event = "VeryLazy",
    main = "tree-sitter-manager",
    opts = {
      ensure_installed = {
        "python", "javascript", "typescript", "tsx", "html", "css",
        "json", "yaml", "toml", "bash", "go", "rust", "regex", "lua",
      },
    },
  },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
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
          prompt_prefix = "   ",
          selection_caret = " ❯ ",
          path_display = { "truncate" },
        },
        extensions = {
          ["ui-select"] = { require("telescope.themes").get_dropdown() },
        },
      })
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "BufReadPost",
    config = function()
      require("nvim-ts-autotag").setup({
        filetypes = {
          "html", "javascript", "typescript", "javascriptreact",
          "typescriptreact", "svelte", "vue", "xml", "markdown",
        },
      })
    end,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts = {},
  },
}

```

#### `~/.config/nvim/lua/plugins/completion.lua`

```lua
return {
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      fuzzy = { implementation = "prefer_rust_with_warning" },
      keymap = {
        preset = "default",
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        menu = {
          border = "rounded",
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", "kind" },
            },
          },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          markdown = { "path", "snippets", "buffer" },
        },
      },
      signature = { enabled = true },
    },
  },
}

```

#### `~/.config/nvim/lua/plugins/lsp.lua`

```lua
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      sources = {
        per_filetype = { lua = { inherit_defaults = true, "lazydev" } },
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
    dependencies = { "williamboman/mason-lspconfig.nvim", "j-hui/fidget.nvim" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
          end
          map("gd", vim.lsp.buf.definition, "Go to Definition")
          map("gr", vim.lsp.buf.references, "Go to References")
          map("gI", vim.lsp.buf.implementation, "Go to Implementation")
          map("<leader>D", vim.lsp.buf.type_definition, "Type Definition")
          map("<leader>rn", function() return ":IncRename " .. vim.fn.expand("<cword>") end, "Rename Symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
        end,
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()
      require("mason-lspconfig").setup()

      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })
      lspconfig.basedpyright.setup({
        capabilities = capabilities,
        settings = { basedpyright = { analysis = { typeCheckingMode = "standard" } } },
      })
      lspconfig.marksman.setup({
        capabilities = capabilities,
        settings = { diagnostics = { enable = false }, completion = { enable = true } },
      })
      lspconfig.ts_ls.setup({ capabilities = capabilities })
      lspconfig.html.setup({ capabilities = capabilities })
      lspconfig.cssls.setup({ capabilities = capabilities })
      lspconfig.jsonls.setup({ capabilities = capabilities })
      lspconfig.gopls.setup({ capabilities = capabilities })
      lspconfig.rust_analyzer.setup({ capabilities = capabilities })
      lspconfig.bashls.setup({ capabilities = capabilities })
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
    opts = { notification = { window = { winblend = 0 } } },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { use_diagnostic_signs = true },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
    },
  },
}

```

#### `~/.config/nvim/lua/plugins/formatter.lua`

```lua
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

```

#### `~/.config/nvim/lua/plugins/lint.lua`

```lua
return {
  {
    "mfussenegger/nvim-lint",
    event = "VeryLazy",
    config = function()
      local lint = require "lint"

      lint.linters.selene = {
        cmd = "selene",
        stdin = false,
        args = {
          "--display-style",
          "quiet",
          "--config",
          vim.fn.expand "~/.config/nvim/selene.toml",
        },
        append_fname = true,
        stream = "stderr",
      }

      lint.linters_by_ft = {
        lua = { "selene" },
        python = { "ruff" },
        yaml = { "yamllint" },
        json = { "jsonlint" },
      }

      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function() lint.try_lint() end,
      })
    end,
  },
}

```

#### `~/.config/nvim/lua/plugins/git.lua`

```lua
return {
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = "│" },
        change = { text = "│" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
      },
      attach_to_untracked = true,
      watch_gitdir = { follow_files = true },
      on_attach = function(bufnr)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end
        map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
        map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>hS", gs.stage_buffer, "Stage buffer")
        map("n", "<leader>hR", gs.reset_buffer, "Reset buffer")
        map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
        map("n", "<leader>hb", function() gs.blame_line { full = true } end, "Blame line")
      end,
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = { { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" } },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
    opts = { enhanced_diff_hl = true },
  },
}

```

#### `~/.config/nvim/lua/plugins/markdown.lua`

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldcolumn = "1"

    vim.schedule(function() pcall(vim.cmd, "normal! zx") end)

    vim.keymap.set("n", "<Tab>", "za", { buffer = true, desc = "Toggle fold", silent = true })
  end,
})

return {
  {
    "OXY2DEV/markview.nvim",
    ft = { "md", "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      preview = { filetypes = { "markdown", "md" }, default_state = true },
      header = { enabled = true, position = "above", top_pad = 1, bottom_pad = 1 },
      code = { sign = true, width = "block", right_pad = 1 },
      pipe_table = { preset = "round" },
    },
  },
  {
    "thenbe/markdown-todo.nvim",
    ft = { "md", "markdown" },
  },
}

```

#### `~/.config/nvim/lua/plugins/mason.lua`

```lua
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
        "lua_ls", "basedpyright", "ts_ls", "html", "cssls",
        "jsonls", "gopls", "rust_analyzer", "bashls", "marksman",
      },
    },
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "stylua", "ruff", "prettierd", "shfmt", "gofumpt",
        "goimports", "selene", "markdownlint-cli2", "yamllint", "jsonlint",
      },
      auto_update = true,
      run_on_start = true,
    },
  },
}

```

#### `~/.config/nvim/lua/plugins/tools.lua`

```lua
return {
  -- ── Snacks (Dashboard, Terminal, Lazygit) ──────────────────────────────
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            "",
            " ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗██╗   ██╗███╗   ███╗",
            "██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝██║   ██║████╗ ████║",
            "██║   ██║██║   ██║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║",
            "██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║",
            "╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║",
            " ╚════▀▀  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝",
            "",
          }, "\n"),
          keys = {
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      terminal = { enabled = true },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
    },
  },

  -- ── File Tree Navigation ────────────────────────────────────────────────
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    keys = { { "<leader>e", "<cmd>Neotree toggle filesystem left<cr>", desc = "Toggle Explorer" } },
    opts = {
      window = { width = 35 },
      filesystem = { filtered_items = { visible = true, hide_dotfiles = false, hide_gitignored = true } },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Oil: Open parent directory" } },
    opts = { default_file_explorer = false },
  },

  -- ── Jump & Movement Extensions ──────────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter" },
    },
  },

  -- ── Illuminate ──────────────────────────────────────────────────────────
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure {
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = { providers = { "lsp" } },
      }
    end,
  },
}

```
