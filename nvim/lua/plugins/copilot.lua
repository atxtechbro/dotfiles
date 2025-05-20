-- GitHub Copilot Configuration for Neovim
-- Minimal configuration that integrates with the existing setup

-- Function to configure Copilot
local setup_copilot = function()
  -- Key mappings for Copilot
  vim.g.copilot_no_tab_map = true -- Disable tab mapping to avoid conflicts
  
  -- Define mappings for suggestion acceptance and navigation
  vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
  vim.api.nvim_set_keymap('i', '<C-]>', 'copilot#Next()', { expr = true, silent = true })
  vim.api.nvim_set_keymap('i', '<C-[>', 'copilot#Previous()', { expr = true, silent = true })

  -- Toggle Copilot with leader+tc
  vim.api.nvim_set_keymap('n', '<leader>tc', ':Copilot toggle<CR>', { noremap = true, silent = true })
  
  -- Print a message to confirm Copilot is loaded
  print("GitHub Copilot configuration loaded")
end

-- Call the setup function
setup_copilot()