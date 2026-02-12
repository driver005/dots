require("lspconfig").svelte.setup({
  -- Ensure your on_attach and capabilities are passed here
  settings = {
    svelte = {
      plugin = {
        typescript = { enabled = true },
      },
    },
  },
})
