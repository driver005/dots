return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        css_variables = {
          filetypes = { "css", "scss", "less", "svelte" },
        },
        clangd = {
          cmd = {
            "/usr/bin/clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
          },
        },
        served = {
          -- Works perfectly out of the box with default settings!
          -- If you need specific init options down the road, they go here.
        },
      },
    },
  },
}
