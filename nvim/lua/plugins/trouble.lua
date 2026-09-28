return {
  {
    "folke/trouble.nvim",
    -- Trouble's own defaults, not overridden: results list is a plain bottom
    -- split (edgy docks it there alongside help/qf/terminal/etc., see
    -- plugins/emacs-behavior.lua), and preview.type="main" shows the
    -- selected item in the MAIN window as you move through the list --
    -- like Emacs' occur/grep-mode, one list buffer + the buffer it points
    -- at, not a dedicated third preview split.
    opts = {
      auto_preview = true,
      follow = true,
      modes = {},
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cl", "<cmd>Trouble lsp toggle focus=false<cr>", desc = "LSP Definitions/References (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
}