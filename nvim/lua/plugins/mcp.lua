-- Both entries here need mcp-hub actually installed (its `build` step is
-- `npm install -g mcp-hub@latest`, opt-in, not every machine ran it).
-- Without `cond`, mcphub.nvim would still register (lazy=true/cmd="MCPHub"
-- only defers WHEN it loads, not WHETHER), and `auto_start = true` would
-- fail the moment :MCPHub was invoked; mcp-diagnostics.nvim is worse --
-- its trigger is `event = "LspAttach"`, which fires on basically every
-- buffer, so without gating it'd try and fail to set up mcphub-backed
-- diagnostics constantly. `cond` fully skips both when the binary's absent.
local function has_mcp_hub()
  return vim.fn.executable("mcp-hub") == 1
end

return {
  {
    "ravitemer/mcphub.nvim",
    cond = has_mcp_hub,
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
    cond = has_mcp_hub,
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
