-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

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
