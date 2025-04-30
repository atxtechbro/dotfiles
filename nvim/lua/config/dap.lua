--[[
  DAP Configuration: Minimal Debugger Setup

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

-- Setup signs in the gutter (sign column):
--   • DapBreakpoint: red dot for breakpoints
--   • DapStopped: arrow for current execution line
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#F44747' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#FFD866' })

vim.fn.sign_define('DapBreakpoint', {text='●', texthl='DapBreakpoint', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='→', texthl='DapStopped', linehl='DapStoppedLine', numhl=''})

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

-- DAP essential key mappings (F5, F9-F12)
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<F5>', "<cmd>lua require('dap').continue()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F10>', "<cmd>lua require('dap').step_over()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F11>', "<cmd>lua require('dap').step_into()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F12>', "<cmd>lua require('dap').step_out()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F9>', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)  -- VS Code style

-- Add alternative to F9 for breakpoint toggle
vim.api.nvim_set_keymap('n', '<leader>bp', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)

-- Command variants for flexibility
vim.api.nvim_create_user_command('BreakpointToggle', function()
    require('dap').toggle_breakpoint()
end, { desc = 'Toggle breakpoint at current line' })

vim.api.nvim_create_user_command('ToggleBreakpoint', function()
    require('dap').toggle_breakpoint()
end, { desc = 'Toggle breakpoint at current line' })

-- Even shorter command for efficiency
vim.api.nvim_create_user_command('TB', function()
    require('dap').toggle_breakpoint()
end, { desc = 'Toggle breakpoint at current line' })