return {
  {
    "BlankTiger/aqf.nvim",
    config = function()
      require("aqf").setup()
      local telescope = require("telescope")
      telescope.load_extension("aqf")
    end,
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
}