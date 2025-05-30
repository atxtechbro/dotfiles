--[[
  DAP Configuration: VS Code-like Debugger Setup with Enhanced UI

  Assumptions:
    • Projects can supply a JSONC launch.json (VS Code schema) at:
         - .vscode/launch.json
         - <project-root>/launch.json
    • nvim-dap's `dap.ext.vscode` loader will register these on startup.
    • If no JSONC is found, fall back to the explicit Lua definitions below.
  
  Features:
    • VS Code-like UI layout with panels for variables, call stack, etc.
    • Enhanced breakpoint visualization and current line highlighting
    • Improved navigation between debug panels
    • Better integration with launch.json files
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

-- Setup signs in the gutter (sign column) with enhanced styling:
--   • DapBreakpoint: red dot for breakpoints
--   • DapBreakpointCondition: diamond for conditional breakpoints
--   • DapLogPoint: circle for logpoints
--   • DapStopped: arrow for current execution line
vim.api.nvim_set_hl(0, 'DapBreakpoint', { fg = '#F44747' })
vim.api.nvim_set_hl(0, 'DapBreakpointCondition', { fg = '#C586C0' })
vim.api.nvim_set_hl(0, 'DapLogPoint', { fg = '#61AFEF' })
vim.api.nvim_set_hl(0, 'DapStopped', { fg = '#FFCC00' })

-- Add line and number highlighting for better visibility
vim.api.nvim_set_hl(0, 'DapBreakpointNum', { fg = '#F44747', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapBreakpointLine', { bg = '#392a32' })
vim.api.nvim_set_hl(0, 'DapBreakpointConditionNum', { fg = '#C586C0', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapBreakpointConditionLine', { bg = '#35283a' })
vim.api.nvim_set_hl(0, 'DapLogPointNum', { fg = '#61AFEF', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapLogPointLine', { bg = '#2d3343' })
vim.api.nvim_set_hl(0, 'DapStoppedNum', { fg = '#FFCC00', bg = '#31353f' })
vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#3e3d2f' })

-- Define signs with enhanced styling
vim.fn.sign_define('DapBreakpoint', {
  text='●',
  texthl='DapBreakpoint',
  linehl='DapBreakpointLine',
  numhl='DapBreakpointNum'
})
vim.fn.sign_define('DapBreakpointCondition', {
  text='◆',
  texthl='DapBreakpointCondition',
  linehl='DapBreakpointConditionLine',
  numhl='DapBreakpointConditionNum'
})
vim.fn.sign_define('DapLogPoint', {
  text='◉',
  texthl='DapLogPoint',
  linehl='DapLogPointLine',
  numhl='DapLogPointNum'
})
vim.fn.sign_define('DapStopped', {
  text='→',
  texthl='DapStopped',
  linehl='DapStoppedLine',
  numhl='DapStoppedNum'
})

-- Virtual text for variable values with enhanced configuration
require('nvim-dap-virtual-text').setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = true,
  show_stop_reason = true,
  commented = false,
  virt_text_pos = 'eol',
  all_frames = false,
  virt_lines = false,
  virt_text_win_col = nil
})

-- Enhanced UI configuration with VS Code-like layout
dapui.setup({
  icons = {
    expanded = "▾",
    collapsed = "▸",
    current_frame = "→"
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  -- VS Code-like layout with panels on the left and bottom
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.40 },
        { id = "breakpoints", size = 0.20 },
        { id = "stacks", size = 0.20 },
        { id = "watches", size = 0.20 },
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        { id = "repl", size = 0.5 },
        { id = "console", size = 0.5 },
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    }
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "single", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = { 
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100 -- Can be integer or nil.
  }
})

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

-- DAP essential key mappings (F5, F6, F9, F10, F12)
local opts = { noremap = true, silent = true }

-- Main debugging controls (F5, F9, F10, F11, F12)
vim.api.nvim_set_keymap('n', '<F5>', "<cmd>lua require('dap').continue()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F10>', "<cmd>lua require('dap').step_over()<CR>", opts)
-- Remap F11 (step into) to <Leader>si for WSL compatibility
-- F11 conflicts with Windows fullscreen toggle in WSL environments
vim.api.nvim_set_keymap('n', '<Leader>si', "<cmd>lua require('dap').step_into()<CR>", opts)
-- Keep F11 mapping for non-WSL environments
vim.api.nvim_set_keymap('n', '<F11>', "<cmd>lua require('dap').step_into()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F6>', "<cmd>lua require('dap').step_into()<CR>", opts)  -- Changed from F11 to F6
vim.api.nvim_set_keymap('n', '<F12>', "<cmd>lua require('dap').step_out()<CR>", opts)
vim.api.nvim_set_keymap('n', '<F9>', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)  -- VS Code style

-- Add alternative to F9 for breakpoint toggle
vim.api.nvim_set_keymap('n', '<leader>bp', "<cmd>lua require('dap').toggle_breakpoint()<CR>", opts)

-- Additional UI-related keymaps
vim.api.nvim_set_keymap('n', '<leader>du', "<cmd>lua require('dapui').toggle()<CR>", opts) -- Toggle UI
vim.api.nvim_set_keymap('n', '<leader>dt', "<cmd>lua require('dap').terminate()<CR>", opts) -- Terminate debug session
vim.api.nvim_set_keymap('n', '<leader>dp', "<cmd>lua require('dap').pause()<CR>", opts) -- Pause execution

-- Call stack navigation with automatic frame focus
vim.api.nvim_set_keymap('n', '<leader>dj', "<cmd>lua require('dap').down()<CR>", opts) -- Move down the stack (older frames)
vim.api.nvim_set_keymap('n', '<leader>dk', "<cmd>lua require('dap').up()<CR>", opts)   -- Move up the stack (newer frames)

-- Additional VS Code-like keymaps for enhanced debugging experience
vim.api.nvim_set_keymap('n', '<leader>B', "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", opts) -- Conditional breakpoint
vim.api.nvim_set_keymap('n', '<leader>lp', "<cmd>lua require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>", opts) -- Logpoint
vim.api.nvim_set_keymap('n', '<leader>dr', "<cmd>lua require('dap').repl.open()<CR>", opts) -- Open REPL
vim.api.nvim_set_keymap('n', '<leader>dl', "<cmd>lua require('dap').run_last()<CR>", opts) -- Run last

-- Hover evaluation
vim.api.nvim_set_keymap('n', '<leader>dh', "<cmd>lua require('dap.ui.widgets').hover()<CR>", opts) -- Hover variables

-- Visual selection evaluation
vim.api.nvim_set_keymap('v', '<leader>de', "<cmd>lua require('dapui').eval()<CR>", opts) -- Evaluate selection

-- Enhanced frame focus with better highlighting
dap.listeners.after.event_stopped['dapui_focus'] = function()
  dapui.open()
  local session = dap.session()
  if session and session.current_frame then
    -- Jump to current frame location
    if session.current_frame.source and session.current_frame.line then
      local source = session.current_frame.source
      local path = source.path or source.sourceReference
      
      if path then
        -- Open file at location and center screen
        -- Use edit! to force buffer switch even with unsaved changes (VS Code-like behavior)
        vim.cmd("edit! " .. vim.fn.fnameescape(path))
        
        -- Before setting cursor position, check if the line exists in the buffer
        local line_count = vim.api.nvim_buf_line_count(0)
        if session.current_frame.line <= line_count then
          vim.api.nvim_win_set_cursor(0, {session.current_frame.line, 0})
          vim.cmd("normal! zz")
          
          -- Highlight the current line with a more visible highlight
          vim.cmd("hi CurrentDebugLine ctermbg=237 guibg=#3a3a3a")
          vim.cmd("match CurrentDebugLine /\\%" .. session.current_frame.line .. "l/")
        else
          -- Line doesn't exist, show a warning
          vim.notify(
            "Debug: Cannot set cursor to line " .. session.current_frame.line .. 
            " (file has only " .. line_count .. " lines)",
            vim.log.levels.WARN
          )
        end
        
        -- Focus on the scopes panel after a short delay
        vim.defer_fn(function()
          -- Try to find and focus the DAP UI window
          local wins = vim.api.nvim_list_wins()
          for _, win in ipairs(wins) do
            local buf = vim.api.nvim_win_get_buf(win)
            local name = vim.api.nvim_buf_get_name(buf)
            if name:match("DAP Scopes") then
              vim.api.nvim_set_current_win(win)
              break
            end
          end
        end, 100)
      end
    end
  end
end

-- Frame change handler - jump to current frame on up/down navigation with enhanced highlighting
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
        -- Use edit! to force buffer switch even with unsaved changes (VS Code-like behavior)
        vim.cmd("edit! " .. vim.fn.fnameescape(path))
        
        -- Before setting cursor position, check if the line exists in the buffer
        local line_count = vim.api.nvim_buf_line_count(0)
        if session.current_frame.line <= line_count then
          vim.api.nvim_win_set_cursor(0, {session.current_frame.line, 0})
          vim.cmd("normal! zz")
          
          -- Highlight the current line with a more visible highlight
          vim.cmd("hi CurrentDebugLine ctermbg=237 guibg=#3a3a3a")
          vim.cmd("match CurrentDebugLine /\\%" .. session.current_frame.line .. "l/")
        else
          -- Line doesn't exist, show a warning
          vim.notify(
            "Debug: Cannot set cursor to line " .. session.current_frame.line .. 
            " (file has only " .. line_count .. " lines)",
            vim.log.levels.WARN
          )
        end
        
        -- Clear the highlight after a short delay
        vim.defer_fn(function()
          vim.cmd("match none")
        end, 1500)
      end
    end
  end
end
