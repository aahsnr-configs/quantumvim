vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.wo.foldmethod = "expr"
    vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.wo.foldenable = true
    vim.wo.foldlevel = 99
    vim.wo.foldcolumn = "1"

    vim.schedule(function()
      pcall(vim.cmd, "normal! zx")
    end)

    vim.keymap.set("n", "<Tab>", "za", { buffer = true, desc = "Toggle fold", silent = true })
    vim.keymap.set("n", "<S-Tab>", function()
      vim.wo.foldlevel = (vim.wo.foldlevel == 99) and 0 or 99
    end, { buffer = true, desc = "Cycle all folds", silent = true })

    vim.keymap.set("n", "<leader>zh", function() vim.wo.foldlevel = 2 end, { buffer = true, desc = "Fold to H2", silent = true })
    vim.keymap.set("n", "<leader>zj", function() vim.wo.foldlevel = math.max(0, vim.wo.foldlevel - 1) end, { buffer = true, desc = "Fold more", silent = true })
    vim.keymap.set("n", "<leader>zk", function() vim.wo.foldlevel = math.min(99, vim.wo.foldlevel + 1) end, { buffer = true, desc = "Fold less", silent = true })
  end,
})

-- Create .markdownlint-cli2.yaml whenever a markdown file is opened or created
local function ensure_markdownlint_config()
  -- Only run for markdown files
  if vim.bo.filetype ~= "markdown" then return end

  local bufname = vim.fn.expand("%:p")
  -- If it's a new empty buffer with no filename, do nothing
  if bufname == "" then return end

  local dir = vim.fn.fnamemodify(bufname, ":h")
  local config_path = dir .. "/.markdownlint-cli2.yaml"

  -- Do NOT overwrite existing configuration
  if vim.fn.filereadable(config_path) == 1 then
    return
  end

  local template = [[
# .markdownlint-cli2.yaml
---
config:
  default: true
  MD013: false          # line length
  MD033: false          # inline HTML allowed
  MD041: false          # first line doesn't need top-level heading
  MD024: false          # allow duplicate headings
fix: false
]]
  vim.fn.writefile(vim.split(template, "\n"), config_path)
  vim.notify(
    "Created .markdownlint-cli2.yaml in " .. dir,
    vim.log.levels.INFO,
    { title = "Markdown" }
  )
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
  pattern = { "*.md", "*.markdown" },
  callback = ensure_markdownlint_config,
})

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      render_modes = { "n", "v" },
      anti_conceal = { enabled = true },
      preset = "obsidian",

      heading = {
        icons = { "❶", "❷", "❸", "❹", "❺", "❻" },
        position = "overlay",
        sign = false,
        width = "block",
        left_pad = 1,
        right_pad = 1,
      },

      latex = { enabled = true, position = "above", top_pad = 1, bottom_pad = 1 },
      code = { sign = true, width = "block", right_pad = 1 },
      pipe_table = { preset = "round" },

      callout = {
        note      = { raw = "[!NOTE]",      rendered = "󰋽 Note",      highlight = "DiagnosticHint" },
        tip       = { raw = "[!TIP]",       rendered = "󰙴 Tip",       highlight = "DiagnosticOk" },
        important = { raw = "[!IMPORTANT]", rendered = "󰋗 Important", highlight = "DiagnosticInfo" },
        warning   = { raw = "[!WARNING]",   rendered = "󰀪 Warning",   highlight = "DiagnosticWarn" },
        caution   = { raw = "[!CAUTION]",   rendered = "󰳦 Caution",   highlight = "DiagnosticError" },
      },

      link      = { enabled = true, image = "󰋩 " },
      checkbox  = { enabled = true, unchecked = { icon = "󰄱 " }, checked = { icon = "󰱔 " } },
      bullet    = { enabled = true, icons = { "●", "○", "◆", "◇" } },
      quote     = { enabled = true, icon = "┃" },
      dash      = { enabled = true, icon = "─" },
    },
  },

  {
    "thenbe/markdown-todo.nvim",
    ft = { "md", "markdown" },
    keys = {
      { "<leader>tu", "<Plug>(markdown-todo-mark-undone)",  desc = "Mark TODO undone" },
      { "<leader>tp", "<Plug>(markdown-todo-mark-pending)", desc = "Mark TODO pending" },
      { "<leader>td", "<Plug>(markdown-todo-mark-done)",    desc = "Mark TODO done" },
      { "<leader>tt", "<Plug>(markdown-todo-cycle)",        desc = "Cycle TODO state" },
    },
    opts = {},
  },
}
