-- GitHub Copilot Configuration for Neovim
--
-- Minimal, focused configuration for GitHub Copilot integration
-- Provides key mappings and toggle functionality
-- Assumption: copilot.vim is installed via Packer

-- Disable tab mapping to avoid conflicts with other completion plugins
vim.g.copilot_no_tab_map = true

-- Define mappings for suggestion acceptance and navigation
vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-]>', 'copilot#Next()', { expr = true, silent = true })
vim.api.nvim_set_keymap('i', '<C-[>', 'copilot#Previous()', { expr = true, silent = true })

-- Toggle Copilot with leader+tc (t for toggle, c for copilot)
vim.api.nvim_set_keymap('n', '<leader>tc', ':Copilot toggle<CR>', { noremap = true, silent = true, desc = 'Toggle GitHub Copilot' })