return {
  {
    "rafamadriz/friendly-snippets",
    lazy = true,
  },

  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      fuzzy = { implementation = "prefer_rust_with_warning" },

      keymap = {
        preset = "default",
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

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
        providers = {},
      },

      signature = { enabled = true },
    },
  },
}
