-- Highlight all occurrences of the word under cursor without needing LSP
-- (Doom's active symbol-overlay). LazyVim core already does this for
-- LSP-attached buffers (document_highlight on CursorHold) -- this only
-- takes over where nothing else will, so plain text/no-LSP filetypes
-- aren't left out, and LSP buffers don't get double-highlighted.
return {
  "tzachar/local-highlight.nvim",
  event = "BufReadPost",
  opts = {
    file_types = {}, -- attach ourselves below, only where LSP won't
  },
  config = function(_, opts)
    require("local-highlight").setup(opts)

    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("local_highlight_no_lsp", { clear = true }),
      callback = function(ev)
        local bufnr = ev.buf
        if vim.bo[bufnr].buftype ~= "" then
          return
        end
        -- Deferred so an LSP client attaching to this same buffer (often
        -- fires right around BufReadPost too) gets a chance to register
        -- first.
        vim.defer_fn(function()
          if not vim.api.nvim_buf_is_valid(bufnr) then
            return
          end
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            if client:supports_method("textDocument/documentHighlight") then
              return
            end
          end
          require("local-highlight").attach(bufnr)
        end, 100)
      end,
    })
  end,
}
