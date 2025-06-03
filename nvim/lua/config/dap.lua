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
        { id = "scopes", size = 0.40 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.20 },
        { id = "watches", size = 0.20 },
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

-- Simple breakpoint signs
vim.fn.sign_define('DapBreakpoint', { text='●', texthl='Error' })
vim.fn.sign_define('DapStopped', { text='→', texthl='WarningMsg' })

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

print("Simplified DAP configuration loaded")
