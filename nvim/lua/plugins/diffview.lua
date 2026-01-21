return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
    },
    keys = {
      { "<leader>hd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>hh", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>hD", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview History" },
      { "<leader>hq", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
  },
}
