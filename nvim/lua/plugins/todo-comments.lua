-- Highlights TODO/FIXME/HACK/NOTE/WARN comments (Doom's active hl-todo
-- module). Was already downloaded as a dependency but never configured --
-- dead weight doing nothing until now. Trouble integration is built in
-- (registers its own Trouble source), so it docks the same bottom-buffer
-- way as diagnostics/qflist/loclist already do.
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
  opts = {},
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
  },
}
