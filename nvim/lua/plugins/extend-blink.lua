return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Corfu-like completion feel (mirrors emacs/doom/+completion.el):
      -- ghost-text preview of the selected item, first item preselected
      -- without auto-inserting it, and a docs popup after a short delay.
      -- (corfu-history's "remember completion history" is blink's
      -- fuzzy.frecency, already on by default.)
      completion = {
        ghost_text = { enabled = true },
        list = { selection = { preselect = true, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
      },
      sources = {
        -- No "minuet" here: Tabby (plugins/tabby.lua) is the inline AI
        -- completion engine now, as its own ghost-text overlay, not a blink
        -- source -- matching Doom Emacs, which has no Codestral capf either.
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
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
