return {
  -- ── Vimtex Framework (LaTeX Lifecycle Control Compiler) ──────────────────────
  {
    "lervag/vimtex",
    lazy = false, -- Vimtex internal engines manage their own optimization loops
    init = function()
      -- Configure view engine execution targets (Zathura PDF Reader standard)
      vim.g.vimtex_view_method = "zathura"

      -- Enable inline continuous parsing feedback mechanics
      vim.g.vimtex_compiler_method = "latexrun"

      -- Retain quiet structural compiler log echo parameters
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
