-- Emoji picker/insert (Doom's active `emoji` module). Via Telescope, same
-- one-picker-UI convention as everything else here (files/grep/buffers/
-- undo-tree). `<leader>ie` under the "insert" group -- Doom's own
-- +which-key.el uses the same `SPC i` prefix for exactly this kind of
-- insert-something-at-point action (file path, ex path, and now emoji).
return {
  "allaman/emoji.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  cmd = "Emoji",
  opts = {},
  config = function(_, opts)
    require("emoji").setup(opts)
    require("telescope").load_extension("emoji")
  end,
  keys = {
    { "<leader>ie", "<cmd>Telescope emoji<cr>", desc = "Insert emoji" },
  },
}
