return {
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "minuet" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            score_offset = 1000,
            transform_items = function(_, items)
              -- Dynamically create a valid highlight group safely
              local palette = require("catppuccin.palettes").get_palette("mocha")
              if palette and palette.lavender then
                vim.api.nvim_set_hl(0, "BlinkCmpKindMinuetAI", { fg = palette.lavender })
              end

              for _, item in ipairs(items) do
                item.kind_icon = "󱚣"
                item.kind_name = "AI"
                item.kind_hl = "BlinkCmpKindMinuetAI" -- Pass the group NAME string
              end
              return items
            end,
          },
          codecompanion = {
            name = "codecompanion",
            module = "codecompanion.providers.completion.blink",
            score_offset = 100,
            transform_items = function(_, items)
              -- Dynamically create a valid highlight group safely
              local palette = require("catppuccin.palettes").get_palette("mocha")
              if palette and palette.blue then
                vim.api.nvim_set_hl(0, "BlinkCmpKindCodeCompanion", { fg = palette.blue })
              end

              for _, item in ipairs(items) do
                item.kind_icon = "󰈸"
                item.kind_name = "CC"
                item.kind_hl = "BlinkCmpKindCodeCompanion" -- Pass the group NAME string
              end
              return items
            end,
          },
        },
      },
    },
  },
}
