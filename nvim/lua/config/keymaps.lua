-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Remap arrow keys to h, j, k, l in normal mode
vim.api.nvim_set_keymap("n", "j", "<Up>", { noremap = true })
vim.api.nvim_set_keymap("n", "k", "<Down>", { noremap = true })
vim.api.nvim_set_keymap("n", "h", "<Left>", { noremap = true })
vim.api.nvim_set_keymap("n", "l", "<Right>", { noremap = true })
