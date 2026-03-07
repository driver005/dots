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
      },
    },
  },
}
