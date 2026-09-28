-- Breadcrumbs/winbar: current function/class shown as you scroll,
-- click-navigable. Coexists with the already-enabled editor.aerial extra
-- (that's a sidebar outline, this is the winbar path -- different UI
-- surface, same underlying symbol info).
return {
  "Bekaboo/dropbar.nvim",
  dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
  event = "BufReadPost",
  opts = {},
}
