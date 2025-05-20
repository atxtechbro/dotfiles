-- Complete Neovim configuration in a single file

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
vim.opt.updatetime = 300      -- Faster completion
vim.opt.timeoutlen = 500      -- By default timeoutlen is 1000 ms
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.mouse = "a"           -- Enable mouse support
vim.opt.cursorline = true     -- Highlight the current line
vim.opt.signcolumn = "yes"    -- Always show the signcolumn

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap Packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Auto-commands for Packer
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost init.lua source <afile> | PackerCompile
  augroup end
]])

-- Plugin definitions
require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- LSP and completion
  use 'neovim/nvim-lspconfig'          -- LSP configuration
  use 'williamboman/mason.nvim'        -- Package manager for LSP servers
  use 'williamboman/mason-lspconfig.nvim' -- Integration with lspconfig
  
  -- Autocompletion
  use 'hrsh7th/nvim-cmp'               -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'           -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'             -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'               -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline'            -- Command line source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'       -- Snippets source for nvim-cmp
  
  -- Snippets
  use 'L3MON4D3/LuaSnip'               -- Snippet engine
  use 'rafamadriz/friendly-snippets'    -- Snippet collection
  
  -- LSP enhancements
  use 'ray-x/lsp_signature.nvim'       -- Show function signature when typing
  use 'folke/lsp-colors.nvim'          -- Better LSP colors
  
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  -- Telescope fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }
  -- Git integration with blame support
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }
  
  -- Debugging with full UI
  use 'mfussenegger/nvim-dap'
  use 'nvim-neotest/nvim-nio'  -- Required dependency for nvim-dap-ui
  use { 'rcarriga/nvim-dap-ui', requires = {'mfussenegger/nvim-dap', 'nvim-neotest/nvim-nio'} }
  use 'theHamsta/nvim-dap-virtual-text'
  use 'nvim-telescope/telescope-dap.nvim'
  
  -- Terminal
  use 'akinsho/toggleterm.nvim'
  
  -- Automatically set up configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)