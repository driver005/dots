-- emacs-behavior.lua
-- Ports Doom Emacs *behaviour* (not keybindings) to LazyVim:
--
--   1. edgy.nvim: transient windows dock as a bottom popup, closed with q
--      (help/qf/Trouble/terminal/overseer/dap-repl/checkhealth/man),
--      instant (no animation), like Emacs' `:ui popup` module.
--   2. Telescope: ivy theme everywhere -> bottom-anchored vertical list,
--      like the Vertico minibuffer.
--   3. noice.nvim: cmdline pinned to the bottom line, not a centered popup
--      -> Emacs' minibuffer lives at the bottom of the frame.
--   4. dressing.nvim: vim.ui.select uses the same ivy telescope layout.

return {
  -- ── 1. edgy: bottom popups for every transient window ──────────────────
  {
    "folke/edgy.nvim",
    opts = function(_, opts)
      opts.animate = opts.animate or {}
      opts.animate.enabled = false
      opts.close_when_all_hidden = true

      opts.bottom = opts.bottom or {}
      vim.list_extend(opts.bottom, {
        { ft = "snacks_terminal", size = { height = 0.3 }, title = "Terminal" },
        { ft = "OverseerList", size = { height = 0.3 }, title = "Overseer" },
        { ft = "dap-repl", size = { height = 0.3 }, title = "DAP REPL" },
        { ft = "dapui_console", size = { height = 0.3 }, title = "DAP Console" },
        { ft = "checkhealth", size = { height = 0.3 }, title = "Checkhealth" },
        { ft = "man", size = { height = 0.3 }, title = "Man" },
      })

      -- Everything edgy docks pops in at 0.3 height by default, matching Doom's
      -- popup module, unless a rule above (or LazyVim's own defaults) says otherwise.
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        bottom = { size = 0.3 },
      })

      return opts
    end,
  },

  -- ── 2. Telescope: ivy theme = bottom vertical list (Vertico feel) ──────
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local ivy = require("telescope.themes").get_ivy()
      ivy.theme = nil
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, ivy)
      return opts
    end,
  },

  -- ── 3. noice: cmdline at the bottom, no centered command palette ───────
  {
    "folke/noice.nvim",
    opts = {
      presets = { command_palette = false },
      cmdline = { view = "cmdline" },
      views = { cmdline_popup = { position = { row = "100%", col = "50%" } } },
    },
  },

  -- ── 4. dressing: vim.ui.select uses the same ivy telescope layout ──────
  {
    "stevearc/dressing.nvim",
    opts = function(_, opts)
      opts.select = vim.tbl_deep_extend("force", opts.select or {}, {
        backend = { "telescope", "builtin" },
        telescope = require("telescope.themes").get_ivy(),
      })
      return opts
    end,
  },
}
