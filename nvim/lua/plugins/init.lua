-- Plugin definitions
return {
  -- LSP and completion
  'neovim/nvim-lspconfig',          -- LSP configuration
  'williamboman/mason.nvim',        -- Package manager for LSP servers
  'williamboman/mason-lspconfig.nvim', -- Integration with lspconfig
  
  -- Autocompletion
  'hrsh7th/nvim-cmp',               -- Completion engine
  'hrsh7th/cmp-nvim-lsp',           -- LSP source for nvim-cmp
  'hrsh7th/cmp-buffer',             -- Buffer source for nvim-cmp
  'hrsh7th/cmp-path',               -- Path source for nvim-cmp
  'hrsh7th/cmp-cmdline',            -- Command line source for nvim-cmp
  'saadparwaiz1/cmp_luasnip',       -- Snippets source for nvim-cmp
  
  -- Snippets
  'L3MON4D3/LuaSnip',               -- Snippet engine
  'rafamadriz/friendly-snippets',    -- Snippet collection
  
  -- LSP enhancements
  'ray-x/lsp_signature.nvim',       -- Show function signature when typing
  'folke/lsp-colors.nvim',          -- Better LSP colors
  
  -- TreeSitter
  {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'},
  
  -- Telescope fuzzy finder
  {'nvim-telescope/telescope.nvim', requires = {'nvim-lua/plenary.nvim'}},
  
  -- Git integration with blame support
  {'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'}},
  
  -- Debugging with full UI
  'mfussenegger/nvim-dap',
  'nvim-neotest/nvim-nio',  -- Required dependency for nvim-dap-ui
  {'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio'}},
  'theHamsta/nvim-dap-virtual-text',
  'nvim-telescope/telescope-dap.nvim',
  
  -- Terminal
  'akinsho/toggleterm.nvim',
  
  -- GitHub Copilot
  'github/copilot.vim',
}