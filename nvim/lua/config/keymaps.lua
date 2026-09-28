-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- <C-g> = Emacs' keyboard-quit: a universal "get out of here", alongside
-- <Esc>, that also reaches the one place <Esc> doesn't cover here -- the
-- cmdline. Normal mode reuses LazyVim's own <Esc> (clear hlsearch + redraw,
-- diffupdate); everywhere else it's a plain escape/abort, matching what
-- <Esc> already does there.
vim.keymap.set("n", "<C-g>", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Escape and clear hlsearch" })
vim.keymap.set({ "i", "v", "o" }, "<C-g>", "<Esc>", { desc = "Escape" })
vim.keymap.set("c", "<C-g>", "<C-c>", { desc = "Abort command line" })
