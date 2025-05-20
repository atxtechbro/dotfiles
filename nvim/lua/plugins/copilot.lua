-- GitHub Copilot Configuration
-- Simple integration with existing Packer setup

return {
  "github/copilot.vim",
  config = function()
    -- Basic settings
    vim.g.copilot_no_tab_map = true
    
    -- Key mappings
    vim.api.nvim_set_keymap('i', '<C-J>', 'copilot#Accept()', {expr = true, silent = true})
    vim.api.nvim_set_keymap('i', '<C-]>', '<Plug>(copilot-next)', {silent = true})
    vim.api.nvim_set_keymap('i', '<C-[>', '<Plug>(copilot-previous)', {silent = true})
    vim.api.nvim_set_keymap('i', '<C-\\>', '<Plug>(copilot-dismiss)', {silent = true})
    
    -- Toggle command
    vim.api.nvim_set_keymap('n', '<leader>tc', ':Copilot toggle<CR>', {noremap = true, silent = true})
  end
}