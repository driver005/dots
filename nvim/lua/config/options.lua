-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Silence LSP file logging
vim.lsp.log.set_level("trace")

vim.filetype.add({ extension = { cppm = "cpp" } })

-- Bigger recentf/savehist, like Emacs' larger recentf-max-saved-items/history
vim.opt.shada = "!,'1000,<100,s10,h"
vim.opt.history = 1000

-- Load API keys / secrets from ~/.bashrc.secrets into the environment so
-- plugins that read env vars (minuet/Codestral, etc.) work no matter how
-- nvim was launched (kitty, tmux dev session, bash -c ...).
do
  local secrets = vim.fn.expand("~/.bashrc.secrets")
  if vim.fn.filereadable(secrets) == 1 then
    for line in io.lines(secrets) do
      local key, val = line:match("^%s*export%s+([%w_]+)=(.+)$")
      if key and val then
        val = val:gsub('^"(.*)"$', "%1"):gsub("^'(.*)'$", "%1")
        if vim.env[key] == nil or vim.env[key] == "" then
          vim.env[key] = val
        end
      end
    end
  end
end
