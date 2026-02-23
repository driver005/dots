return {
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
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
