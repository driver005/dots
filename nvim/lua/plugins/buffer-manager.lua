return {
  {
    "j-morano/buffer_manager.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<M-Space>",
        function()
          require("buffer_manager.ui").toggle_quick_menu()
        end,
        desc = "Buffer menu",
      },
      {
        "<M-m>",
        function()
          require("buffer_manager.ui").toggle_quick_menu()
          vim.defer_fn(function()
            vim.fn.feedkeys("/")
          end, 50)
        end,
        desc = "Buffer menu (search)",
      },
      {
        "<M-j>",
        function()
          require("buffer_manager.ui").nav_next()
        end,
        desc = "Next buffer",
      },
      {
        "<M-k>",
        function()
          require("buffer_manager.ui").nav_prev()
        end,
        desc = "Prev buffer",
      },
    },
    opts = {
      line_keys = "1234567890",
      select_menu_item_commands = {
        edit = { key = "<CR>", command = "edit" },
        v = { key = "<C-v>", command = "vsplit" },
        h = { key = "<C-s>", command = "split" },
      },
      focus_alternate_buffer = false,
      short_file_names = true,
      short_term_names = true,
      loop_nav = false,
      show_cols = "number",
      toggle_key_bindings = { "q", "<ESC>" },
      use_shortcuts = false,
      win_position = { h = 0.5, v = 0.5 },
      order_buffers = "lastused",
    },
  },
}
