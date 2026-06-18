return {
  {
    "Mythos-404/xmake.nvim",
    lazy = false,
    build = function(plugin)
      local file = plugin.dir .. "/lua/xmake/runner_wrapper.lua"
      local lines = vim.fn.readfile(file)
      for i, line in ipairs(lines) do
        lines[i] = line:gsub("vim.tbl_isempty%(opts%.env%)", "vim.tbl_isempty(opts.env or {})")
      end
      vim.fn.writefile(lines, file)
    end,
    cond = function()
      return vim.fn.findfile("xmake.lua", vim.fn.expand("%:p:h") .. ";") ~= ""
        or vim.fn.findfile("xmake.lua", vim.fn.getcwd() .. ";") ~= ""
    end,
    dependencies = {
      { "folke/snacks.nvim", optional = true },
      { "mfussenegger/nvim-dap", optional = true },
      { "rcarriga/nvim-notify", optional = true },
      { "stevearc/dressing.nvim", optional = true },
    },
    opts = {
      on_save = {
        reload_project_info = true,
        lsp_compile_commands = {
          enable = true,
          output_dir = "build",
        },
      },
      lsp = {
        enable = true,
      },
      runner = {
        type = "snacks",
        config = {
          snacks = {
            position = "float",
            interactive = true,
            auto_close = false,
          },
        },
      },
      execute = {
        type = "snacks",
        config = {
          snacks = {
            position = "float",
            interactive = true,
            auto_close = false,
          },
        },
      },
      debuger = {
        rulus = { "debug", "releasedbg" }, -- note: upstream spells it "rulus"
        dap = {
          name = "Xmake Debug",
          type = "codelldb",
          request = "launch",
          cwd = "${workspaceFolder}",
          console = "integratedTerminal",
          stopOnEntry = false,
          runInTerminal = false,
        },
      },
      notify = {
        icons = {
          error = "",
          successfully = "",
        },
        spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        refresh_rate_ms = 100,
        timeout = 2000, -- 2 seconds, adjust to taste
      },
    },
    keys = {
      { "<leader>m", desc = "+xmake" },
      { "<leader>mb", "<cmd>Xmake build<cr>", desc = "Build" },
      { "<leader>mc", "<cmd>Xmake clean<cr>", desc = "Clean" },
      { "<leader>mr", "<cmd>Xmake run<cr>", desc = "Run (pick target)" },
      { "<leader>md", "<cmd>Xmake debug<cr>", desc = "Debug (pick target)" },
      { "<leader>mR", "<cmd>Xmake run all<cr>", desc = "Run All" },
      { "<leader>mD", "<cmd>Xmake debug all<cr>", desc = "Debug All" },
      { "<leader>mm", "<cmd>Xmake mode<cr>", desc = "Set Mode" },
      { "<leader>mp", "<cmd>Xmake plat<cr>", desc = "Set Platform" },
      { "<leader>ma", "<cmd>Xmake arch<cr>", desc = "Set Architecture" },
      { "<leader>mt", "<cmd>Xmake toolchain<cr>", desc = "Set Toolchain" },
      {
        "<leader>ms",
        function()
          local ok, info = pcall(require, "xmake.info")
          if ok then
            info.target.current = ""
          end
          vim.cmd("Xmake run")
        end,
        desc = "Select Target",
      },
    },
    config = function(_, opts)
      require("xmake").setup(opts)
      -- Populate Info.mode.current (and all other info) immediately on startup
      -- so the first Xmake debug sees the real current mode and skips the mode-switch
      vim.schedule(function()
        require("xmake.info").all_defer_reload()
      end)
    end,
  },
}
