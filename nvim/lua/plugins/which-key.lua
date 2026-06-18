return {
  "folke/which-key.nvim",
  opts = {
    spec = {
      { mode = { "n", "v" }, { "<leader>h", name = "git hunk", icon = "📝" } },
      { mode = { "n", "v" }, { "<leader>gn", name = "Neogit", icon = "🐙" } },
      { mode = { "n", "v" }, { "<leader>fW", name = "Sudo Write", icon = "󰌋 " } },
      {
        "<leader>d<Space>",
        function()
          require("which-key").show({
            keys = "<leader>d",
            loop = true,
          })
        end,
        desc = "DAP Hydra Mode",
      },
    },
  },
}
