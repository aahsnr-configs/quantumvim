# 🌌 QuantumVim: A Modular, Production-Grade Neovim Configuration

A clean, blistering-fast, ideologically modular Neovim configuration built around Lua, optimized for modern software engineering workflows. This setup leverages a fully decoupled architecture utilizing **Lazy.nvim** to balance an aggressive, asynchronous plugin-loading posture with deep language server integrations.

---

## 🎨 Philosophy & Design Pillars

- **Modular Architecture:** No monolithic runtime files. Every system component—from core system options to single plugin environments—lives in isolated, declarative structures.
- **Asynchronous Execution Engine:** Built using `blink.cmp` (Rust-powered fuzzy sorting), `conform.nvim` (non-blocking formatting on save), and `nvim-lint` (decoupled diagnostic reporting) to guarantee a zero-lag user interface.
- **Aesthetic Continuity:** Uniform visual layers provided by **Catppuccin Mocha**, featuring clean, border-padded completion menus and absolute status/buffer lines.
- **Ecosystem Portability:** Declarative dependencies managed natively via `mason.nvim` and `mason-tool-installer.nvim`, making cross-platform machine provisioning automated and reliable.

---

## 🏗️ Configuration Architecture

The runtime structure maps logically down into specialized domains, separating user specifications from plugin definitions:

```text
~/.config/nvim/
├── init.lua                # Runtime Bootstrapper & Lazy.nvim Setup
├── options.lua             # System Options (Indentation, UI Engine, Key Timers)
├── keymaps.lua             # Core Editor & Window Navigation Mappings
├── autocmds.lua            # High-Level Structural Event Handlers
│
├── .stylua.toml            # Code Formatting Constraints (StyLua Target)
├── selene.toml             # Static Analysis Code Quality Profile (Selene)
├── neovim.yml              # Custom Neovim Global Ecosystem Matrix for Selene
│
└── lua/
    └── plugins/            # Lazy-loaded Feature Modules
        ├── ui.lua          # Canvas Layout: Catppuccin, Bufferline, Lualine, Indents
        ├── editor.lua      # UX Enhancements: Telescope, Treesitter, Todo-Comments
        ├── completion.lua  # Engine: Blink.cmp & Snippets Integration
        ├── lsp.lua         # LSP Client Configurations & Diagnostic Router (Trouble)
        ├── formatter.lua   # Non-blocking Execution Layer via Conform.nvim
        ├── lint.lua        # Asynchronous Static Code Quality Gateways via Nvim-Lint
        ├── git.lua         # Version Control Layers (Gitsigns, Fugitive, Diffview)
        ├── markdown.lua    # Advanced Folding & Documentation Engineering Tools
        └── tools.lua       # Native Utilities (Snacks Dash, Flash Jump, Illuminate)

```

---

## ⚡ Complete Keybindings Ledger

### Core Editor Operations

| Keybinding   | Mode   | Action          | Target / Context                              |
| ------------ | ------ | --------------- | --------------------------------------------- |
| `jk`         | Insert | `<Esc>`         | Swift, ergonomic exit to Normal Mode          |
| `<leader>nh` | Normal | `:nohlsearch`   | Instantly flushes current search highlighters |
| `<A-j>`      | Normal | `:m .+1==`      | Drags active code line down 1 row             |
| `<A-k>`      | Normal | `:m .-2==`      | Drags active code line up 1 row               |
| `<A-j>`      | Visual | Selection Shift | Shifts entire highlighted code block down     |
| `<A-k>`      | Visual | Selection Shift | Shifts entire highlighted code block up       |

### Window & Split Navigation

| Keybinding   | Mode   | Action      | Target / Context                                |
| ------------ | ------ | ----------- | ----------------------------------------------- |
| `<leader>sv` | Normal | `:vsplit`   | Spawns a vertical window split                  |
| `<leader>sh` | Normal | `:split`    | Spawns a horizontal window split                |
| `<leader>se` | Normal | `<C-w>=`    | Distributes all window sizes completely equally |
| `<leader>sx` | Normal | `:close`    | Dismantles current window split safely          |
| `<C-h>`      | Normal | Focus Left  | Targets adjacent window layout to the left      |
| `<C-j>`      | Normal | Focus Down  | Targets adjacent window layout below            |
| `<C-k>`      | Normal | Focus Up    | Targets adjacent window layout above            |
| `<C-l>`      | Normal | Focus Right | Targets adjacent window layout to the right     |

### Feature & Tooling Overrides

| Keybinding   | Mode   | Action             | Domain Provider                      |
| ------------ | ------ | ------------------ | ------------------------------------ |
| `<leader>cf` | Normal | `conform.format()` | Async Code Formatter Engine          |
| `<leader>ff` | Normal | File Finder        | Telescope Project Search             |
| `<leader>fg` | Normal | Live Grep          | Telescope String Query across files  |
| `<leader>fb` | Normal | Active Buffers     | Telescope Memory Matrix              |
| `<leader>fh` | Normal | Help Tags          | Telescope Internal Manuals           |
| `gco`        | Normal | Add comment below  | Comment Architecture Core Extension  |
| `gcO`        | Normal | Add comment above  | Comment Architecture Core Extension  |
| `gcA`        | Normal | Add comment at EOL | Comment Architecture Core Extension  |
| `s`          | Global | Leap Forward/Back  | Flash.nvim Target-jump Engine        |
| `S`          | Global | Node Selection     | Flash.nvim TS Treesitter Selector    |
| `<leader>xx` | Normal | Workspace Toggle   | Trouble.nvim Central Diagnostics Hub |
| `<leader>gs` | Normal | `:Git`             | Fugitive Source View Layout          |
| `<leader>gd` | Normal | Diff View Open     | Diffview.nvim Revision Comparison    |
| `<leader>gD` | Normal | Diff View Close    | Diffview.nvim Cleanup                |

---

## 🛠️ Automated Ecosystem Provisioning

The workspace uses dynamic integration loops via Mason. Language Servers, Linters, and Formatters auto-bootstrap instantly on environment startup.

### Multi-Language Target Ledger

| Language Domain          | Language Server (LSP)      | Formatter Integration      | Linter Engine       |
| ------------------------ | -------------------------- | -------------------------- | ------------------- |
| **Lua**                  | `lua_ls`                   | `stylua`                   | `selene`            |
| **Python**               | `basedpyright`             | `ruff_format` / `ruff_fix` | `ruff`              |
| **Markdown**             | `marksman`                 | `prettierd`                | `markdownlint-cli2` |
| **YAML**                 | Built-in                   | `prettierd`                | `yamllint`          |
| **JSON / JSONC**         | `jsonls`                   | `prettierd`                | `jsonlint`          |
| **Go**                   | `gopls`                    | `gofumpt` / `goimports`    | Go Vet / LSP        |
| **Rust**                 | `rust_analyzer`            | `rustfmt`                  | Cargo Engine        |
| **Web (JS/TS/HTML/CSS)** | `ts_ls` / `html` / `cssls` | `prettierd`                | LSP Diagnostics     |
| **Shell Shell/Bash**     | `bashls`                   | `shfmt`                    | Shellcheck Pipeline |

---

## 🚀 Installation & Initialization Blueprint

### 1. Prerequisites (System Layer Dependencies)

Ensure your host machine has the following utilities installed prior to initialization:

```bash
# macOS (via Homebrew)
brew install neovim git ripgrep fd luarocks coreutils

# Linux (Debian/Ubuntu based systems)
sudo apt install neovim git ripgrep fd-find luarocks build-essential -y

```

### 2. Configuration Setup

Clone this workspace deployment strictly down into your local user runtime environment directory:

```bash
git clone <your-repository-url> ~/.config/nvim

```

### 3. Toolchain & Ecosystem Deployment

1. Fire up Neovim (`nvim`).
2. **Lazy.nvim** will engage instantly, mapping dependencies, retrieving source structures, and parsing targets.
3. **Mason Tool Installer** will concurrently launch a background worker sequence, automatically downloading all specified Language Servers, Formatters, and Linters.
4. Restart Neovim once the tracking screens report total compilation completion.

---

## ⚙️ Key Architectural Implementations

### Code Formatting Pipelines (`conform.nvim`)

The environment maintains an explicit non-blocking, format-on-save lifecycle with an explicit 1000ms execution timeout constraint:

```lua
format_on_save = function(bufnr)
  if not vim.g.autoformat then return end
  return { timeout_ms = 1000, lsp_format = "fallback" }
end

```

_Global Toggle:_ Execute `:lua vim.g.autoformat = not vim.g.autoformat` to temporarily disable formatting globally.

### Rigorous Linting Lifecycles (`selene` / `nvim-lint`)

Static verification steps execute asynchronously across high-frequency user interactions: `BufWritePost`, `BufReadPost`, and `InsertLeave`.

To prevent directory tracking faults when processing custom standard libraries (`std = "neovim"`), the engine forces direct paths straight to the base configuration files:

```lua
lint.linters.selene = {
  cmd = "selene",
  stdin = false,
  args = {
    "--display-style", "quiet",
    "--config", vim.fn.expand("~/.config/nvim/selene.toml"),
  },
  append_fname = true,
  stream = "stderr",
}

```
