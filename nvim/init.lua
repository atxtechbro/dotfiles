-- Complete Neovim configuration in a single file

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true

-- Bootstrap Packer if not installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
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
  use 'neovim/nvim-lspconfig'           -- LSP configuration
  use 'williamboman/mason.nvim'         -- Package manager for LSP servers
  use 'williamboman/mason-lspconfig.nvim' -- Integration with lspconfig
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  -- Telescope fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/plenary.nvim'}}
  }
  -- Git integration with blame support
  use 'lewis6991/gitsigns.nvim'
  -- Git integration with blame support
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'}
  }
  -- Automatically set up configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Keymaps
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
vim.keymap.set('n', '<leader>t', ':split | terminal<CR>', { silent = true })
vim.keymap.set('n', '<leader>vt', ':vsplit | terminal<CR>', { silent = true })
vim.keymap.set('i', 'jk', '<Esc>')

-- TreeSitter Configuration
local treesitter_config = function()
  require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all" (parsers with maintainers)
    ensure_installed = {
      "lua", "vim", "vimdoc", "python",
      "html", "css", "json", "bash", "markdown"
    },
    modules = {},
    ignore_install = {},
    sync_install = false,
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<CR>',
        scope_incremental = '<CR>',
        node_incremental = '<TAB>',
        node_decremental = '<S-TAB>',
      },
    },
  }
  
  -- Folding configuration
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldenable = false
  vim.opt.foldlevel = 99
end

pcall(treesitter_config)

-- Telescope Configuration
local telescope_config = function()
  local telescope_status, telescope = pcall(require, 'telescope')
  if telescope_status then
    telescope.setup {}
    print("Telescope loaded successfully")
  else
    print("Telescope not found")
  end
end

pcall(telescope_config)

-- Setup Mason for managing LSP servers
local mason_setup = function()
  require('mason').setup()
  require('mason-lspconfig').setup({
    automatic_installation = true,
    ensure_installed = {
      'lua_ls',      -- Lua
      'pyright',     -- Python
      'html',        -- HTML
      'cssls',       -- CSS
      'jsonls',      -- JSON
      'bashls',      -- Bash
      'marksman',    -- Markdown
    }
  })
end

pcall(mason_setup)


-- Set up LSP keybindings when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  end,
})

-- Configure language servers
local setup_language_servers = function()
  local lspconfig = require('lspconfig')
  
  -- Lua LSP configuration with special settings for Neovim development
  lspconfig.lua_ls.setup({
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }  -- Recognize 'vim' as a global
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),  -- Add Neovim runtime to library
          checkThirdParty = false,  -- Disable third party checking
        },
        telemetry = {
          enable = false,  -- Disable telemetry
        },
      },
    },
  })

  -- Python
  lspconfig.pyright.setup({})

  -- HTML
  lspconfig.html.setup({})

  -- CSS
  lspconfig.cssls.setup({})

  -- JSON
  lspconfig.jsonls.setup({})

  -- Bash
  lspconfig.bashls.setup({})

  -- Markdown
  lspconfig.marksman.setup({})
end

pcall(setup_language_servers)

-- Quick clear file content keybinding
vim.keymap.set('n', '<leader>da', ':%d<CR>', { noremap = true, silent = true, desc = "Delete all content" })

-- If we're starting for the first time (after bootstrap), run PackerSync
if packer_bootstrap then
  vim.cmd([[autocmd User PackerComplete lua print("Packer setup complete!")]])
  require('packer').sync()
end

-- Simple GitSigns setup for git blame functionality
pcall(function()
  require('gitsigns').setup {
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
    }
  }
end)

print("Neovim configuration loaded")
