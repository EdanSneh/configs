-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Source shared vim/nvim settings (options, keymaps, autocmds, abbreviations)
-- Sourced on VeryLazy so leader (Space) is set by LazyVim before our keymaps
vim.cmd("source " .. vim.fn.stdpath("config") .. "/shared.vim")
