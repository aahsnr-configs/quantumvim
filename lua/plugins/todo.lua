-- lua/plugins/todo.lua
-- Optimised Checkmate configuration for your Catppuccin + render-markdown stack.
-- https://github.com/bngarren/checkmate.nvim

return {
  {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- activate in all markdown buffers
    dependencies = {
      -- highlight re-apply on ColorScheme (already a core autocmd, listed for clarity)
    },
    opts = function()
      -- ── Highlight helpers (resilient to color scheme changes) ──────────
      local function set_highlights()
        -- Safely retrieve the live Catppuccin palette dynamically
        local has_catppuccin, cp_palettes = pcall(require, "catppuccin.palettes")
        if not has_catppuccin then
          return
        end

        local c = cp_palettes.get_palette("mocha") or {}
        if next(c) == nil then
          return
        end

        local hl = function(name, opts)
          opts.default = true -- yield to colorscheme if it defines the group
          vim.api.nvim_set_hl(0, name, opts)
        end

        hl("CheckmateTodoUnchecked", { fg = c.overlay1 })
        hl("CheckmateTodoChecked", { fg = c.green, strikethrough = true })
        hl("CheckmateTodoInProgress", { fg = c.yellow, bold = true })
        hl("CheckmateTodoOnHold", { fg = c.peach })
        hl("CheckmateTodoCancelled", { fg = c.surface2, strikethrough = true })

        hl("CheckmateMetaStarted", { fg = c.sky })
        hl("CheckmateMetaDone", { fg = c.green })
        hl("CheckmateMetaDue", { fg = c.red })
        hl("CheckmateMetaPriority", { fg = c.mauve })
      end

      -- Apply once now, then keep in sync on every future colorscheme change.
      set_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = set_highlights,
        group = vim.api.nvim_create_augroup("CheckmateHighlights", { clear = true }),
      })

      -- ── Core configuration ─────────────────────────────────────────────
      return {
        enabled = true,
        notify = true,

        -- Override the default narrow scope (todo.md, *.todo) to all markdown
        files = { "*.md", "*.markdown" },

        -- ── State markers ─────────────────────────────────────────────────
        -- Plain GFM markers so render-markdown can parse and overlay icons.
        -- The `name` field appears as optional virtual text next to the line.
        todo_states = {
          unchecked = {
            marker = "[ ]",
            name = "TODO",
            style = { hl_group = "CheckmateTodoUnchecked" },
          },
          checked = {
            marker = "[x]",
            name = "DONE",
            style = { hl_group = "CheckmateTodoChecked" },
          },
          custom = {
            {
              marker = "[-]",
              name = "IN-PROGRESS",
              style = { hl_group = "CheckmateTodoInProgress" },
            },
            {
              marker = "[~]",
              name = "ON-HOLD",
              style = { hl_group = "CheckmateTodoOnHold" },
            },
            {
              marker = "[/]",
              name = "CANCELLED",
              style = { hl_group = "CheckmateTodoCancelled" },
            },
          },
        },

        -- ── Metadata (inline @tags) ──────────────────────────────────────
        metadata = {
          started = {
            key = "started",
            label = "󰥔 started", -- nf-md-clock_outline
            hl_group = "CheckmateMetaStarted",
            on_state = { "IN-PROGRESS" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          done = {
            key = "done",
            label = "󰄬 done", -- nf-md-check_circle_outline
            hl_group = "CheckmateMetaDone",
            on_state = { "DONE" },
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          due = {
            key = "due",
            label = "󰃰 due", -- nf-md-calendar_clock
            hl_group = "CheckmateMetaDue",
            value = { type = "datetime", format = "%Y-%m-%d" },
          },
          priority = {
            key = "priority",
            label = "󰃙 priority", -- nf-md-flag_outline
            hl_group = "CheckmateMetaPriority",
            value = { type = "string" },
          },
        },

        -- ── Keymaps (all buffer-local in markdown files) ─────────────────
        keys = {
          -- Core toggles
          ["<leader>Tt"] = {
            rhs = "<cmd>Checkmate toggle<CR>",
            desc = "Toggle todo state",
            modes = { "n", "v" },
          },
          ["<leader>Tc"] = {
            rhs = "<cmd>Checkmate check<CR>",
            desc = "Mark DONE",
            modes = { "n", "v" },
          },
          ["<leader>Tu"] = {
            rhs = "<cmd>Checkmate uncheck<CR>",
            desc = "Mark TODO (unchecked)",
            modes = { "n", "v" },
          },

          -- State cycling
          ["<leader>T="] = {
            rhs = "<cmd>Checkmate cycle_next<CR>",
            desc = "Cycle to next state",
            modes = { "n", "v" },
          },
          ["<leader>T-"] = {
            rhs = "<cmd>Checkmate cycle_previous<CR>",
            desc = "Cycle to previous state",
            modes = { "n", "v" },
          },

          -- Create new todo
          ["<leader>Tn"] = {
            rhs = "<cmd>Checkmate create<CR>",
            desc = "New todo at same level",
            modes = { "n", "v" },
          },

          -- Quick metadata inserts
          ["<leader>Td"] = {
            rhs = "<cmd>Checkmate add_metadata due<CR>",
            desc = "Add @due date",
            modes = "n",
          },
          ["<leader>Tp"] = {
            rhs = "<cmd>Checkmate add_metadata priority<CR>",
            desc = "Add @priority",
            modes = "n",
          },

          -- Archive completed items
          ["<leader>Ta"] = {
            rhs = "<cmd>Checkmate archive<CR>",
            desc = "Archive completed todos",
            modes = "n",
          },

          -- Picker (search/filter todos in buffer)
          ["<leader>Ts"] = {
            rhs = "<cmd>Checkmate select_todo<CR>",
            desc = "Search todos (picker)",
            modes = "n",
          },
        },

        -- ── Picker ───────────────────────────────────────────────────────
        picker = {
          provider = "snacks", -- uses your existing snacks.nvim installation
          -- fallback: mini.pick → telescope (if snacks not available)
        },

        -- ── Archive section ──────────────────────────────────────────────
        archive = {
          heading = "## ✔ Archive",
          auto_fold = true,
        },

        -- ── Linting ──────────────────────────────────────────────────────
        -- You already have markdownlint-cli2 via nvim-lint – disable the built‑in linter.
        linter = {
          enabled = false,
        },
      }
    end,
  },
}
