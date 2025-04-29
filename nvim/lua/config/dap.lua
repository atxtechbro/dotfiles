--[[
  DAP Configuration: Lua + optional VS Code–style JSONC loader

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

-- Python adapter configuration
dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = {'-m', 'debugpy.adapter'},
}
dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = '${file}',
    pythonPath = function()
      local venv_path = vim.fn.getcwd() .. '/venv/bin/python'
      if vim.fn.executable(venv_path) == 1 then
        return venv_path
      end
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
require('telescope').load_extension('dap')

-- DAP key mappings
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<F5>', "<cmd>lua require('dap').continue()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F10>', "<cmd>lua require('dap').step_over()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F11>', "<cmd>lua require('dap').step_into()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F12>', "<cmd>lua require('dap').step_out()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F9>', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)  -- VS Code style
vim.api.nvim_set_keymap('n', '<leader>B', "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>lp', "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>dr', "<cmd>lua require('dap').repl.open()<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>du', "<cmd>lua require('dapui').toggle()<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>dc', "<cmd>lua require('telescope').extensions.dap.commands{}<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>db', "<cmd>lua require('telescope').extensions.dap.list_breakpoints{}<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>dv', "<cmd>lua require('telescope').extensions.dap.variables{}<CR>", opts)
vim.api.nvim_set_keymap('n', '<leader>df', "<cmd>lua require('telescope').extensions.dap.frames{}<CR>", opts)