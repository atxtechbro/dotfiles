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
  
  -- Autocompletion
  use 'hrsh7th/nvim-cmp'                -- Completion engine
  use 'hrsh7th/cmp-nvim-lsp'            -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'              -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'                -- Path source for nvim-cmp
  use 'hrsh7th/cmp-cmdline'             -- Command line source for nvim-cmp
  use 'saadparwaiz1/cmp_luasnip'        -- Snippets source for nvim-cmp
  
  -- Snippets
  use 'L3MON4D3/LuaSnip'                -- Snippet engine
  use 'rafamadriz/friendly-snippets'    -- Snippet collection
  
  -- LSP enhancements
  use 'ray-x/lsp_signature.help'        -- Show function signature when typing
  use 'folke/lsp-colors.nvim'           -- Better LSP colors
  
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

-- Keymaps
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
vim.keymap.set('i', 'jk', '<Esc>')

-- TreeSitter Configuration
local treesitter_config = function()
  require('nvim-treesitter.configs').setup {
    -- A list of parser names, or "all" (parsers with maintainers)
    ensure_installed = {
      "lua", "vim", "vimdoc", "python",
      "html", "css", "json", "xml", "bash", "markdown"
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
  require('mason').setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })
  
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
      'lemminx',     -- XML
    }
  })
end

pcall(mason_setup)

-- Set up autocompletion
local cmp_setup = function()
  local cmp = require('cmp')
  local luasnip = require('luasnip')
  
  -- Load friendly snippets
  require("luasnip.loaders.from_vscode").lazy_load()
  
  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
    })
  })
  
  -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
end

pcall(cmp_setup)

-- Setup function signature help
local signature_setup = function()
  require('lsp_signature').setup({
    bind = true,
    handler_opts = {
      border = "rounded"
    },
    hint_enable = true,
    hint_prefix = "🔍 ",
    hint_scheme = "String",
    hi_parameter = "LspSignatureActiveParameter",
    max_height = 12,
    max_width = 120,
    floating_window = true,
    fix_pos = false,
    always_trigger = false,
    auto_close_after = nil,
    transparency = nil,
    toggle_key = '<C-k>', -- toggle signature on and off in insert mode
  })
end

pcall(signature_setup)


-- Set up LSP keybindings when a server attaches to a buffer
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = {buffer = event.buf}
    
    -- Hover documentation
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    
    -- Jump to definition
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    
    -- Jump to declaration
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    
    -- Jump to implementation
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    
    -- Jump to type definition
    vim.keymap.set('n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    
    -- List all references
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    
    -- Symbol rename
    vim.keymap.set('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    
    -- Code actions
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    vim.keymap.set('v', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
    
    -- Show diagnostics in a floating window
    vim.keymap.set('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
    
    -- Move to previous/next diagnostic
    vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>', opts)
    vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>', opts)
    
    -- Show signature help (when typing function parameters)
    vim.keymap.set('i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    
    -- Format document
    vim.keymap.set('n', '<leader>f', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    
    -- Workspace management
    vim.keymap.set('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>', opts)
    vim.keymap.set('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>', opts)
    vim.keymap.set('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>', opts)
    
    -- Print a message to confirm LSP is attached
    print("LSP attached for filetype: " .. vim.bo[event.buf].filetype)
  end,
})

-- Configure language servers
local setup_language_servers = function()
  local lspconfig = require('lspconfig')
  local capabilities = require('cmp_nvim_lsp').default_capabilities()
  
  -- Lua LSP configuration with special settings for Neovim development
  lspconfig.lua_ls.setup({
    capabilities = capabilities,
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
  lspconfig.pyright.setup({
    capabilities = capabilities,
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          useLibraryCodeForTypes = true,
          typeCheckingMode = "basic"
        }
      }
    }
  })

  -- HTML
  lspconfig.html.setup({
    capabilities = capabilities
  })

  -- CSS
  lspconfig.cssls.setup({
    capabilities = capabilities
  })

  -- JSON
  lspconfig.jsonls.setup({
    capabilities = capabilities,
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    }
  })

  -- Bash
  lspconfig.bashls.setup({
    capabilities = capabilities
  })

  -- Markdown
  lspconfig.marksman.setup({
    capabilities = capabilities
  })
  -- XML LSP (Lemminx)
  lspconfig.lemminx.setup({
    capabilities = capabilities
  })
  
  -- Set diagnostic signs
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
  
  -- Configure diagnostics display
  vim.diagnostic.config({
    virtual_text = {
      prefix = '●', -- Could be '■', '▎', 'x'
      source = "if_many",
    },
    float = {
      source = "always",
      border = "rounded",
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
  
  -- Configure hover and signature help
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
    vim.lsp.handlers.hover, {
      border = "rounded",
    }
  )
  
  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
    vim.lsp.handlers.signature_help, {
      border = "rounded",
    }
  )
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

-- Load Debug Adapter Protocol (DAP) configuration
pcall(function()
  require('config.dap')
  print("Debug Adapter Protocol (DAP) configuration loaded from 'config.dap'")
end)

-- Load ToggleTerm terminal integration configuration
pcall(function()
  require('config.terminal')
  print("ToggleTerm terminal integration loaded from 'config.terminal'")
end)

-- Ensure cursor line is enabled
vim.cmd([[
  augroup CursorLineHighlight
    autocmd!
    autocmd VimEnter,ColorScheme * highlight CursorLine guibg=#87FFD7 blend=0
  augroup END
]])

print("Neovim configuration loaded")

-- Add mappings to copy filename or full path to clipboard
-- <leader>cf - Copy just the filename
vim.keymap.set('n', '<leader>cf', function()
  local filename = vim.fn.expand('%:t')
  vim.fn.setreg('+', filename)
  print('Filename copied to clipboard: ' .. filename)
end, { desc = 'Copy filename to clipboard' })

-- <leader>cp - Copy full path
vim.keymap.set('n', '<leader>cp', function()
  local fullpath = vim.fn.expand('%:p')
  vim.fn.setreg('+', fullpath)
  print('Full path copied to clipboard: ' .. fullpath)
end, { desc = 'Copy full path to clipboard' })
-- TODO: XML editing settings (remove when comfortable)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'xml',
  callback = function()
    -- Basic XML editing preferences
    local opt = vim.opt_local
    opt.expandtab = true         -- Use spaces instead of tabs
    opt.shiftwidth = 2           -- Indent by 2 spaces
    opt.tabstop = 2                  -- Number of spaces per Tab character
    opt.softtabstop = 2              -- Number of spaces a Tab counts for while editing
    opt.autoindent = true            -- Copy indent from current line on new lines
    opt.cindent = false              -- Disable C-style automatic indentation
    -- Folding using Treesitter
    opt.foldmethod = 'expr'           -- Use expression-based folding
    opt.foldexpr = 'nvim_treesitter#foldexpr()'  -- Use Treesitter for folding expressions
    opt.foldenable = false            -- Keep folds closed by default
    opt.foldlevel = 99                -- Open most folds by default (up to level 99)
    -- Pretty-print XML via xmllint (<leader>f)
    vim.keymap.set('n', '<leader>f', ':%!xmllint --format -<CR>', { buffer = true, silent = true, desc = 'Pretty print XML' })
  end
})
