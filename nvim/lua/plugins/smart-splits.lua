return {
  "mrjones2014/smart-splits.nvim",
  build = "./kitty/install-kittens.bash",
  keys = {
    -- A-hjkl: nvim <-> tmux pane nav (replaces vim-tmux-navigator, which
    -- caused a cursor-jump-on-scroll redraw glitch inside tmux). smart-splits
    -- falls through to tmux at the nvim edge natively.
    {
      "<A-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Move to left window",
    },
    {
      "<A-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Move to right window",
    },
    {
      "<A-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Move to below window",
    },
    {
      "<A-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Move to above window",
    },
    -- NOTE: <leader>w h/j/k/l is deliberately NOT bound anywhere. LazyVim's
    -- <leader>w which-key group has its own trigger mapping with
    -- nowait=true (:h :map-nowait), which means <leader>w always fires
    -- immediately -- Neovim can never see a longer <leader>wh/j/k/l as one
    -- typed sequence, buffer-local or not (nowait's prefix-ambiguity
    -- resolution wins regardless of scope). Leaving Trouble is tracked by
    -- focus alone instead (config/autocmds.lua's WinLeave hook), so it
    -- fires for however focus actually leaves: <A-hjkl> above, <C-w>*,
    -- mouse, or <leader>w's own numbered window-jump list.
  },
}
