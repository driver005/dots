return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    dependencies = { "nvim-lua/plenary.nvim", "saghen/blink.cmp" },
    opts = {
      provider = "codestral",
      provider_options = {
        codestral = {
          model = "codestral-latest",
          api_key = "CODESTRAL_API_KEY",
          end_point = "https://codestral.mistral.ai/v1/fim/completions",
          stream = true,
          optional = {
            max_tokens = 128,
            top_p = 0.9,
          },
          system = function()
            local ok, vc = pcall(require, "vectorcode.cacher")
            if not ok then
              return nil
            end
            local cacher = vc.lsp -- or .default if async_backend = "default"
            local bufnr = vim.api.nvim_get_current_buf()
            if not cacher.buf_is_registered(bufnr) then
              return nil
            end
            local results = cacher.query_from_cache(bufnr)
            if not results or #results == 0 then
              return nil
            end
            local parts = { "Relevant files from the codebase:\n" }
            for _, r in ipairs(results) do
              table.insert(parts, ("-- %s\n%s"):format(r.path, r.document))
            end
            return table.concat(parts, "\n")
          end,
        },
      },

      blink = {
        enable_auto_complete = true,
      },

      virtualtext = {
        auto_trigger_ft = { "*" },
        auto_trigger_ignore_ft = {},
        keymap = {
          accept = "<A-a>",
          accept_line = "<A-l>",
          accept_n_lines = "<A-z>",
          next = "<A-]>",
          prev = "<A-[>",
          dismiss = "<A-e>",
        },
      },

      context_window = 16000,
      context_ratio = 0.75,
      throttle = 1000,
      debounce = 400,
      request_timeout = 5,
      n_completions = 2,
      add_single_line_entry = true,
      notify = "warn",
    },
  },
}
