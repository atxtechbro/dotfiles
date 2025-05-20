--[[
  DAP Configuration: Full Debugger Setup with UI

  Assumptions:
    • Projects can supply a JSONC launch.json (VS Code schema) at:
         - .vscode/launch.json
         - <project-root>/launch.json
    • nvim-dap's `dap.ext.vscode` loader will register these on startup.
    • If no JSONC is found, fall back to the explicit Lua definitions below.
]]
-- Attempt to load VS Code launch.json configurations
do
  local ok, vscode = pcall(require, 'dap.ext.vscode')
  if ok then
    -- try standard .vscode/launch.json
    pcall(vscode.load_launchjs)
    -- fallback to root-level launch.json
    local fallback = vim.fn.getcwd() .. '/launch.json'
    if vim.fn.filereadable(fallback) == 1 then
      pcall(vscode.load_launchjs, fallback)
    end
  end
end
local dap = require('dap')
local dapui = require('dapui')

-- Setup signs in the gutter (sign column):
--   • DapBreakpoint: red dot for breakpoints
--   • DapBreakpointCondition: red dot for conditional breakpoints
--   • DapLogPoint: red dot for logpoints
--   • DapStopped: arrow for current execution line
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#F44747' })
vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#F44747' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#F44747' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#FFD866' })

vim.fn.sign_define('DapBreakpoint', {text='●', texthl='DapBreakpoint', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointCondition', {text='●', texthl='DapBreakpointCondition', linehl='', numhl=''})
vim.fn.sign_define('DapLogPoint', {text='●', texthl='DapLogPoint', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='→', texthl='DapStopped', linehl='DapStoppedLine', numhl=''})

-- Virtual text for variable values, etc.
require('nvim-dap-virtual-text').setup()

-- DAP UI setup
dapui.setup()

-- Automatically open and close DAP UI
dap.listeners.after.event_initialized['dapui_config'] = function()
  dapui.open()
end
dap.listeners.before.event_terminated['dapui_config'] = function()
  dapui.close()
end
dap.listeners.before.event_exited['dapui_config'] = function()
  dapui.close()
end

-- Python adapter configuration with absolute path to debugpy
-- First, try to use the absolute path to debugpy adapter
local debugpy_adapter_path = vim.fn.expand('$HOME/.local/uv-tools/debugpy/adapter')
local debugpy_module_exists = (vim.fn.glob(debugpy_adapter_path) ~= '')

if debugpy_module_exists then
  -- Use absolute path if debugpy adapter exists
  dap.adapters.python = {
    type = 'executable',
    command = 'python',
    args = {debugpy_adapter_path},
  }
else
  -- Fallback to module import (requires debugpy in PYTHONPATH)
  dap.adapters.python = {
    type = 'executable',
    command = 'python',
    args = {'-m', 'debugpy.adapter'},
  }
  
  -- Print a warning message to help with troubleshooting
  vim.notify(
    "Debugpy adapter path not found at: " .. debugpy_adapter_path .. 
    "\nFalling back to module import. If debugging fails, run: " ..
    "\n~/dotfiles/nvim/scripts/python-debug-install.sh",
    vim.log.levels.WARN
  )
end
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      -- Check for virtual environment in current directory
      local venv_path = vim.fn.getcwd() .. '/.venv/bin/python'
      if vim.fn.executable(venv_path) == 1 then
        return venv_path
      end
      
      -- Check for virtual environment in parent directories
      local cwd = vim.fn.getcwd()
      local parent = vim.fn.fnamemodify(cwd, ':h')
      while parent ~= cwd do
        local parent_venv = parent .. '/.venv/bin/python'
        if vim.fn.executable(parent_venv) == 1 then
          return parent_venv
        end
        cwd = parent
        parent = vim.fn.fnamemodify(cwd, ':h')
      end
      
      -- Check for system Python
      return 'python'
    end,
  },
}

-- C/C++ adapter (lldb)
dap.adapters.lldb = {
  type = 'executable',
  command = 'lldb-vscode',
  name = 'lldb',
}
dap.configurations.cpp = {
  {
    name = 'Launch',
    type = 'lldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
    args = {},
  },
}
dap.configurations.c = dap.configurations.cpp

-- Telescope DAP integration
pcall(function()
  require('telescope').load_extension('dap')
end)

-- DAP essential key mappings (F5, F9-F12)
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<F5>', "<cmd>lua require('dap').continue()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F10>', "<cmd>lua require('dap').step_over()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F11>', "<cmd>lua require('dap').step_into()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F12>', "<cmd>lua require('dap').step_out()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F9>', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)  -- VS Code style

-- Add alternative to F9 for breakpoint toggle
vim.api.nvim_set_keymap('n', '<leader>bp', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)

-- Additional UI-related keymaps
vim.api.nvim_set_keymap('n', '<leader>du', "<cmd>lua require('dapui').toggle()<CR>", opts) -- Toggle UI
vim.api.nvim_set_keymap('n', '<leader>dt', "<cmd>lua require('dap').terminate()<CR>", opts) -- Terminate debug session

-- Call stack navigation with automatic frame focus
vim.api.nvim_set_keymap('n', '<leader>dj', "<cmd>lua require('dap').down()<CR>", opts) -- Move down the stack (older frames)
vim.api.nvim_set_keymap('n', '<leader>dk', "<cmd>lua require('dap').up()<CR>", opts)   -- Move up the stack (newer frames)

-- Add frame focus handler to highlight current frame and jump to its location
dap.listeners.after.event_stopped['dapui_focus'] = function()
  dapui.open()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-w>l', true, false, true), 'n', false)
end

-- Frame change handler - jump to current frame on up/down navigation
dap.listeners.after.scopes['dapui_frame_focus'] = function()
  -- Jump to the current frame's location automatically
  local session = dap.session()
  if session and session.current_frame then
    dap.runtime_info = dap.runtime_info or {}
    dap.runtime_info.current_frame = session.current_frame
    
    -- Focus frame in UI and jump to location
    if session.current_frame.source and session.current_frame.line then
      local source = session.current_frame.source
      local path = source.path or source.sourceReference
      
      if path then
        -- Open file at location and center screen
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.api.nvim_win_set_cursor(0, {session.current_frame.line, 0})
        vim.cmd("normal! zz")
        
        -- Briefly highlight the current line
        vim.cmd("hi CurrentDebugLine ctermbg=237 guibg=#3a3a3a")
        vim.cmd("match CurrentDebugLine /\\%" .. session.current_frame.line .. "l/")
        
        -- Clear the highlight after a short delay
        vim.defer_fn(function()
          vim.cmd("match none")
        end, 1500)
      end
    end
  end
end