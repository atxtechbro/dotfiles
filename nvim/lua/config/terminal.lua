-- ToggleTerm configuration for integrated terminal
--
-- Provides an easy horizontally split terminal at <leader>t
-- Assumption: toggleterm.nvim is installed via Packer
require('toggleterm').setup({
  size = 20,
  open_mapping = [[<c-\\>]],
  shade_terminals = true,
  shading_factor = 2,
  start_in_insert = true,
  persist_size = true,
  direction = 'horizontal',
  close_on_exit = true,
  shell = vim.o.shell,
})

-- Map <leader>t to toggle the terminal
vim.api.nvim_set_keymap('n', '<leader>t', '<cmd>ToggleTerm<CR>', { noremap = true, silent = true, desc = 'Toggle integrated terminal' })