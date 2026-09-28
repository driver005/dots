return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      scroll = { enabled = false },
      -- *scratch* buffer / session restore (config/autocmds.lua) replaces the
      -- dashboard, like Emacs starting on *scratch* instead of a splash screen.
      dashboard = { enabled = false },
      picker = {
        sources = {
          -- This handles the file picker (e.g., <leader><space>)
          files = {
            hidden = true,
            ignored = false,
          },
          -- This handles the live grep (e.g., <leader>/)
          grep = {
            hidden = true,
            ignored = false,
          },
          -- This handles the Side Tree / Explorer
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
