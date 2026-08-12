return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
  -- Transparent background so nvim shows the terminal (kitty) background,
  -- matching tmux (which is bg=default / transparent too).
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
    },
  },
}
