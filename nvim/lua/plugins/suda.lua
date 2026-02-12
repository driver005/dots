return {
  "lambdalisue/vim-suda",
  event = "BufReadPre",
  -- Keymaps are defined here for better lazy-loading
  keys = {
    {
      "<leader>fW",
      "<cmd>SudaWrite<cr>",
    },
  },
  config = function()
    -- Automatically prompt for sudo if you open a file without permissions
    vim.g.suda_smart_edit = 1
  end,
}
