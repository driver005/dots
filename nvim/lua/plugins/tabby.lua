-- Tabby: inline AI completion from the local tabbyml.service (self-hosted,
-- repo-indexed), the same server Doom Emacs' tabby.el talks to
-- (emacs/doom/plugin/ai/tabby, tabby/tabby-install.sh). Sole inline
-- completion engine here too, matching Doom (no Codestral capf alongside
-- it there; minuet.nvim disabled here for the same reason, see minuet.lua).
--
-- vim-tabby has no blink.cmp source: it renders suggestions as its own
-- ghost-text overlay, independent of the completion menu.
return {
  {
    "TabbyML/vim-tabby",
    -- Fully skip the plugin (not just lazy-load it) on any machine where
    -- tabby-agent-lts isn't installed -- tabby/tabby-install.sh is opt-in
    -- per setup.sh, so this dotfiles repo runs on machines that never ran
    -- it. `cond` is checked once at startup, before lazy.nvim even
    -- registers the plugin, so it's zero-cost there instead of registering
    -- an InsertEnter trigger that would just try and fail to launch it.
    cond = function()
      return vim.fn.executable(vim.fn.expand("~/.local/bin/tabby-agent-lts")) == 1
    end,
    event = "InsertEnter",
    dependencies = { "neovim/nvim-lspconfig" },
    init = function()
      -- Launches tabby-agent under Node 22 via nvm, not bare `npx tabby-agent`:
      -- the agent's bundled EnvHttpProxyAgent breaks under Node 26's fetch
      -- (see tabby/tabby-agent-lts.sh for the full writeup). Reads server
      -- endpoint/token from ~/.tabby-client/agent/config.toml, already
      -- written by tabby/tabby-install.sh.
      vim.g.tabby_agent_start_command = { vim.fn.expand("~/.local/bin/tabby-agent-lts"), "--stdio" }
      vim.g.tabby_inline_completion_trigger = "auto"

      -- <Tab> stays with blink.cmp's own menu; free Alt-keys instead
      -- (same convention minuet.nvim used before being replaced by this).
      vim.g.tabby_inline_completion_keybinding_accept = "<A-a>"
      vim.g.tabby_inline_completion_keybinding_trigger_or_dismiss = "<A-e>"
    end,
  },
}
