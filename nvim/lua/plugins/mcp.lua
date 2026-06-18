return {
  {
    "ravitemer/mcphub.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    build = "npm install -g mcp-hub@latest",
    lazy = true,
    cmd = "MCPHub",
    opts = {
      config = vim.fn.expand("~/.config/mcp/servers.json"),
      auto_start = true,
      port = 37373,
      log_level = "warn",
      on_ready = function()
        vim.notify("󰈸 MCP Hub ready", vim.log.levels.INFO)
      end,
    },
  },
  {
    "georgeharker/mcp-diagnostics.nvim",
    dependencies = { "ravitemer/mcphub.nvim" },
    event = "LspAttach",
    config = function()
      require("mcp-diagnostics").setup({
        mode = "mcphub",
        max_diagnostics = 50,
        max_references = 20,
        show_source = true,
      })
    end,
  },
}
