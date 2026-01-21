return {
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "Neogit" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = {
      integrations = {
        diffview = true,
      },
      kind = "tab",
      disable_commit_confirmation = true,
      signs = {
        section = { "▸", "▾" },
        item = { "▸", "▾" },
        hunk = { "", "" },
      },
    },
  },
}
