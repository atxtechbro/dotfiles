--[[
  Simplified DAP Configuration
  
  This is a minimal configuration focused on core debugging functionality.
  All complex UI and navigation features have been removed to isolate any issues.
]]

-- Load the DAP module
local dap = require('dap')
local dapui = require('dapui')

-- Basic UI configuration
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "→" },
  mappings = {
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        -- Display call stack and breakpoints for essential debugging information
        -- while maintaining a cleaner interface
        { id = "stacks", size = 0.6 },
        { id = "breakpoints", size = 0.4 },
      },
      size = 40,
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size = 0.25,
      position = "bottom",
    }
  },
})

-- First, define the colors for the signs to match the retro theme.
-- This uses standard terminal highlight groups for broad compatibility.
vim.api.nvim_set_hl(0, 'DapBreakpointSign', { fg = '#cc241d' }) -- Muted Red
vim.api.nvim_set_hl(0, 'DapStoppedSign', { fg = '#fabd2f' }) -- Muted Yellow

-- Now, define the signs using classic, professional symbols.
vim.fn.sign_define('DapBreakpoint', {
  text = '●',
  texthl = 'DapBreakpointSign',
  linehl = '',
  numhl = ''
})

vim.fn.sign_define('DapStopped', {
  text = '→',
  texthl = 'DapStoppedSign',
  linehl = '',
  numhl = ''
})

-- Basic UI open/close
dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

-- Python adapter configuration
-- Try to use debugpy from virtual environment first
local function get_python_path()
  -- Check for virtual environment in current directory
  local venv_path = vim.fn.getcwd() .. '/.venv/bin/python'
  if vim.fn.executable(venv_path) == 1 then
    return venv_path
  end
  
  -- Check for system Python
  return 'python'
end

-- Configure Python adapter
dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = {'-m', 'debugpy.adapter'},
}

-- Python configuration
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = get_python_path,
    justMyCode = true,  -- Only debug user-written code
  },
}

-- Load launch.json if available
pcall(function()
  require('dap.ext.vscode').load_launchjs(nil, { python = {'py'} })
end)

-- 1. Automatically load breakpoints from the session file
dap.listeners.after.event_initialized['dap_load_breakpoints'] = function()
  require('dap.session').load() -- Use .session and .load()
  print("DAP session loaded.")
end

-- 2. Automatically save breakpoints when you quit Neovim
vim.api.nvim_create_autocmd("VimLeavePre", {
  callback = function()
    require('dap.session').save() -- Use .session and .save()
  end
})

-- Simple key mappings with direct function calls
local opts = { noremap = true, silent = true }

-- Debug control keys
vim.keymap.set('n', '<F5>', function() 
  print("F5 pressed - continue")
  require('dap').continue() 
end, opts)

vim.keymap.set('n', '<F10>', function() 
  print("F10 pressed - step over")
  require('dap').step_over() 
end, opts)

vim.keymap.set('n', '<F11>', function() 
  print("F11 pressed - step into")
  require('dap').step_into() 
end, opts)

vim.keymap.set('n', '<F12>', function() 
  print("F12 pressed - step out")
  require('dap').step_out() 
end, opts)

vim.keymap.set('n', '<F9>', function() 
  print("F9 pressed - toggle breakpoint")
  require('dap').toggle_breakpoint() 
end, opts)

-- Alternative mappings
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, opts)
vim.keymap.set('n', '<leader>dso', function() require('dap').step_over() end, opts)
vim.keymap.set('n', '<leader>dsi', function() require('dap').step_into() end, opts)
vim.keymap.set('n', '<leader>dsx', function() require('dap').step_out() end, opts)
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, opts)

-- UI controls
vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, opts)
vim.keymap.set('n', '<leader>dt', function() require('dap').terminate() end, opts)

-- 3. Corrected keymap for manual saving
vim.keymap.set('n', '<leader>dS', function() -- d(ap) S(ave)
    require('dap.session').save() -- Use .session and .save()
    print("DAP breakpoints saved to session file.")
end, opts)

print("Simplified DAP configuration loaded")
