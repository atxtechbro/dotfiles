-- ~/.config/nvim/init.lua
-- Complete Neovim configuration in a single file

-- IMPORTANT: Set leader key first, before anything else loads
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus' -- System clipboard integration
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.completeopt = 'menuone,noselect'
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes' -- Reserve space for diagnostic icons

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
  
  -- Completion plugins
  use 'hrsh7th/nvim-cmp'                -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'            -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'              -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'                -- Path source for nvim-cmp
  use 'L3MON4D3/LuaSnip'                -- Snippet engine
  use 'saadparwaiz1/cmp_luasnip'        -- Snippets source for nvim-cmp
  
  -- Treesitter for better syntax highlighting
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  
  -- Telescope fuzzy finder
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/plenary.nvim'}}
  }
  
  -- File icons (for Telescope)
  use 'nvim-tree/nvim-web-devicons'
  
  -- Automatically set up configuration after cloning packer.nvim
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- Keymaps
local opts = { noremap = true, silent = true }

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)

-- Keep yanked text when pasting over selection
vim.keymap.set('v', 'p', '"_dP', opts)

-- Clear search highlights
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>', opts)

-- Quick save
vim.keymap.set('n', '<leader>w', ':write<CR>', opts)

-- Buffer navigation
vim.keymap.set('n', '<S-l>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-h>', ':bprevious<CR>', opts)

-- Telescope mappings using direct key mappings, not leader
vim.keymap.set('n', '<F5>', '<cmd>Telescope find_files<cr>', opts)
vim.keymap.set('n', '<F6>', '<cmd>Telescope live_grep<cr>', opts)
vim.keymap.set('n', '<F7>', '<cmd>Telescope buffers<cr>', opts)
vim.keymap.set('n', '<F8>', '<cmd>Telescope help_tags<cr>', opts)

-- Also add the leader-based keymaps (for when leader works correctly)
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)

-- TreeSitter Configuration
local treesitter_config = function()
  require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all" (parsers with maintainers)
    ensure_installed = {
      "lua", "vim", "vimdoc", "python",
      "html", "css", "json", "bash", "markdown"
    },
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

-- Add nvim-cmp capabilities to lspconfig
local setup_lsp_capabilities = function()
  local lspconfig = require('lspconfig')
  local cmp_nvim_lsp = require('cmp_nvim_lsp')
  
  local lspconfig_defaults = lspconfig.util.default_config
  lspconfig_defaults.capabilities = vim.tbl_deep_extend(
    'force',
    lspconfig_defaults.capabilities,
    cmp_nvim_lsp.default_capabilities()
  )
end

pcall(setup_lsp_capabilities)

-- Set up LSP keybindings when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    
    -- Hover documentation
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    
    -- Code navigation
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    
    -- Workspace management
    vim.keymap.set('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
    vim.keymap.set('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
    vim.keymap.set('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
    
    -- Code actions
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    
    -- Alternative mappings using <leader>
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    
    -- Diagnostics
    vim.keymap.set('n', '<leader>d', '<cmd>lua vim.diagnostic.open_float()<cr>', opts)
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
    vim.keymap.set('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<cr>', opts)
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

-- Set up nvim-cmp for autocompletion
local setup_completion = function()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  
  cmp.setup({
    sources = {
      { name = 'nvim_lsp' },  -- LSP completions
      { name = 'luasnip' },   -- Snippets source
      { name = 'buffer' },    -- Text in current buffer
      { name = 'path' },      -- File paths
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),  -- Trigger completion
      ['<C-e>'] = cmp.mapping.abort(),         -- Close completion window
      ['<CR>'] = cmp.mapping.confirm({ select = true }),  -- Accept selected item
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
    }),
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
  })
end

pcall(setup_completion)

-- Quick clear file content keybinding
vim.keymap.set('n', '<leader>da', ':%d<CR>', { noremap = true, silent = true, desc = "Delete all content" })

-- If we're starting for the first time (after bootstrap), run PackerSync
if packer_bootstrap then
  vim.cmd([[autocmd User PackerComplete lua print("Packer setup complete!")]])
  require('packer').sync()
end

print("Neovim configuration loaded")
