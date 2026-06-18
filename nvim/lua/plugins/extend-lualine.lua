return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections = opts.sections or {}
      opts.sections.lualine_x = opts.sections.lualine_x or {}
      opts.sections.lualine_y = opts.sections.lualine_y or {}

      -- table.insert(opts.sections.lualine_x, 1, {
      --   function()
      --     local ok, tc = pcall(require, "token-count")
      --     if not ok then
      --       return ""
      --     end
      --     local count = tc.get_count and tc.get_count() or 0
      --     if not count or count == 0 then
      --       return ""
      --     end
      --     if count > 1000 then
      --       return ("󰗻 %dk"):format(math.floor(count / 1000))
      --     end
      --     return ("󰗻 %d"):format(count)
      --   end,
      --   cond = function()
      --     return package.loaded["token-count"] ~= nil
      --   end,
      --   color = function()
      --     local ok, tc = pcall(require, "token-count")
      --     if not ok then
      --       return {}
      --     end
      --     local count = (tc.get_count and tc.get_count()) or 0
      --     local pct = count / 200000
      --     local pal = require("catppuccin.palettes").get_palette("mocha")
      --     if pct > 0.8 then
      --       return { fg = pal.red }
      --     elseif pct > 0.5 then
      --       return { fg = pal.yellow }
      --     else
      --       return { fg = pal.subtext0 }
      --     end
      --   end,
      -- })
      --
      table.insert(opts.sections.lualine_y, {
        function()
          return vim.g.octocode_progress or ""
        end,
        cond = function()
          return vim.g.octocode_progress ~= nil and vim.g.octocode_progress ~= ""
        end,
        color = { fg = "#a6e3a1" },
      })

      table.insert(opts.sections.lualine_y, {
        function()
          return "󱃖 watch"
        end,
        cond = function()
          return vim.g.octocode_watch == true and (vim.g.octocode_progress == nil or vim.g.octocode_progress == "")
        end,
        color = { fg = "#89dceb" },
      })

      -- ── Minuet AI completion status (lualine_y) ───────────────────────
      table.insert(opts.sections.lualine_y, {
        require("minuet.lualine"),
        display_name = "both",
        provider_model_separator = ":",
        display_on_idle = true,
        icon = "󱚣",
        color = { fg = "#89b4fa" },
      })

      return opts
    end,
  },
}
