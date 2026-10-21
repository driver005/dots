local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Light mode on ChromeOS (Crostini): core LazyVim + Java extra only, none of
-- lua/plugins/* (no AI agents, codecompanion, tabby, mcp, ...).
-- Override with NVIM_LIGHT=1 / NVIM_LIGHT=0.
local light = vim.env.NVIM_LIGHT
if light == nil or light == "" then
  vim.g.nvim_light = vim.uv.fs_stat("/opt/google/cros-containers") ~= nil
else
  vim.g.nvim_light = light == "1"
end

local spec
if vim.g.nvim_light then
  -- LazyVim reads enabled extras from this file instead of lazyvim.json
  -- (resolved via init.lua's real path: ~/.config/nvim is per-file symlinks)
  local root = vim.fs.dirname(vim.uv.fs_realpath(vim.fn.stdpath("config") .. "/init.lua"))
  vim.g.lazyvim_json = root .. "/lazyvim-light.json"
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins.colorscheme" },
  }
else
  spec = {
    -- add LazyVim and import its plugins
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    -- import/override with your plugins
    { import = "plugins" },
  }
end

require("lazy").setup({
  spec = spec,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = {
    enabled = true, -- check for plugin updates periodically
    notify = false, -- notify on update
  }, -- automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
