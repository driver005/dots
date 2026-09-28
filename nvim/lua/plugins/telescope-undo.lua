-- Visual undo tree (Emacs vundo/undo-tree, what SPC u u opens in most
-- Doom configs), via Telescope instead of a standalone split -- keeps the
-- one-picker-UI convention this setup already has everywhere else.
return {
  "debugloop/telescope-undo.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>uu", "<cmd>Telescope undo<cr>", desc = "Undo Tree" },
  },
  opts = {},
  config = function(_, opts)
    require("telescope").setup({ extensions = { undo = opts } })
    require("telescope").load_extension("undo")
  end,
}
