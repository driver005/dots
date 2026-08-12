return {
  -- ADD: auto-continue markdown checkbox/bullet lists.
  -- Type "- [ ] task", hit Enter (insert mode) -> a fresh "- [ ] " appears.
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_checkbox_markers = " x"
      vim.g.bullets_nested_checkboxes = 1
      vim.g.bullets_outline_levels = { "std-" }
    end,
  },

  -- CHECK: toggle a checkbox done/undone. Keys are markdown-buffer-local so
  -- they never collide with LazyVim's global maps.
  --   <CR>       (normal/visual) -> toggle [ ] <-> [x]
  --   <leader>cn                 -> insert a new checkbox line
  {
    "opdavies/toggle-checkbox.nvim",
    ft = { "markdown", "text", "gitcommit" },
    config = function()
      local function keys(buf)
        vim.keymap.set({ "n", "x" }, "<CR>", function()
          require("toggle-checkbox").toggle()
        end, { buffer = buf, silent = true, desc = "Toggle checkbox" })
        vim.keymap.set("n", "<leader>cn", "o- [ ] <Esc>A", { buffer = buf, silent = true, desc = "New checkbox line" })
      end
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "text", "gitcommit" },
        callback = function(ev)
          keys(ev.buf)
        end,
      })
      -- apply to the buffer that triggered the plugin load, if applicable
      if vim.tbl_contains({ "markdown", "text", "gitcommit" }, vim.bo.filetype) then
        keys(0)
      end
    end,
  },
}
