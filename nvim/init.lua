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

vim.keymap.set('i', '<Caps_Lock>', '<Esc>')

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
