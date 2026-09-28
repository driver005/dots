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
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
        },
        served = {
          -- Works perfectly out of the box with default settings!
          -- If you need specific init options down the road, they go here.
        },
        -- Grammar checking (Doom's active `grammar` module). Bundles
        -- LanguageTool internally, runs over plain LSP -- no separate
        -- server to stand up, installed via mason like any other server
        -- here. Scoped to prose-ish filetypes (same set LazyVim's own
        -- spell-check autocmd targets): grammar-checking code would be
        -- noise.
        ltex_plus = {
          filetypes = { "markdown", "gitcommit", "text", "org" },
          settings = {
            ltex = { language = "en-US" },
          },
        },
      },
    },
  },
}
