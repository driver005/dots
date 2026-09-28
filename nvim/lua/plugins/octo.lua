-- Doom's (magit +forge): browse/review GitHub PRs and issues as real,
-- persistent editing buffers -- not edgy-docked, same category as a
-- normal code buffer (like a magit-forge buffer in Emacs), not a popup.
-- Needs `gh` CLI authenticated (`gh auth status`).
return {
  "pwntester/octo.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Octo",
  opts = {},
  keys = {
    { "<leader>go", "<cmd>Octo<cr>", desc = "Octo (GitHub)" },
  },
}
