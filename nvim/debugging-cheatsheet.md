# Neovim Debugging Cheatsheet

A comprehensive guide for debugging in Neovim with DAP (Debug Adapter Protocol) integration.

## Keybindings

| Keybinding | Description |
|------------|-------------|
| `<F5>` | Start/continue debugging |
| `<leader>dc` | Alternative continue (if F5 has issues) |
| `<F9>` | Toggle breakpoint (VS Code style) |
| `<leader>bp` | Toggle breakpoint (alternative to F9) |
| `<F10>` | Step over |
| `<leader>dso` | Step over (alternative to F10) |
| `<F11>` | Step into (may conflict with Windows fullscreen in WSL) |
| `<F6>` | Step into (alternative to F11) |
| `<leader>si` | Step into (WSL-compatible alternative) |
| `<leader>dsi` | Step into (another alternative) |
| `<F12>` | Step out |
| `<leader>dsx` | Step out (alternative to F12) |
| `<leader>du` | Toggle DAP UI (variables, stack, watches) |
| `<leader>dt` | Terminate debug session |
| `<leader>dp` | Pause execution |
| `<leader>dj` | Move down the call stack (older frames) |
| `<leader>dk` | Move up the call stack (newer frames) |

## Debugging UI Elements

When debugging is active, the following UI components appear:

- **Variables panel**: Shows local and global variables in the current scope
- **Watch panel**: Shows expressions you're monitoring during the debugging session
- **Breakpoints panel**: Lists all active breakpoints
- **Stacks panel**: Shows the call stack with frames you can navigate
- **Console**: For input/output and program interaction

The UI opens automatically when a debugging session starts and closes when it ends.

## Debugging Workflows

### Basic Workflow

1. Set breakpoints in your code with `<F9>` or `<leader>bp`
2. Start debugging with `<F5>`
3. Step through code with `<F10>` (step over), `<F11>` (step into), `<F12>` (step out)
4. Inspect variables in the DAP UI
5. Continue execution with `<F5>` until the next breakpoint
6. Terminate session with `<leader>dt` when done

### Advanced Usage

- Navigate the call stack with `<leader>dj` (down) and `<leader>dk` (up)
- Add expressions to the Watch panel to monitor their values
- Use conditional breakpoints for complex debugging scenarios
- Set logpoints to log values without stopping execution

## Language-Specific Debugging

### Python

- The DAP configuration automatically detects Python virtual environments:
  - Checks for `.venv/bin/python` in the current directory
  - Falls back to system Python if no virtual environment is found
- Python debugging uses `justMyCode: true` by default to focus only on your code
- If debugging fails with a "module not found" error for debugpy:
  - Ensure you've run `~/dotfiles/nvim/scripts/python-debug-install.sh`
  - For project-specific debugging, you can install debugpy in your virtual environment:
    ```bash
    # Activate your virtual environment
    source .venv/bin/activate
    # Install debugpy
    pip install debugpy
    ```

### C/C++

- Uses LLDB for debugging C/C++ applications
- When starting a debug session, you'll be prompted for the path to the executable
- Default suggestion will be `<current_directory>/build/`
- You can specify command line arguments for your program in the launch configuration

## Configuration Options

### launch.json Support

The DAP configuration supports VS Code-style launch.json files. Two locations are checked:
- `.vscode/launch.json` (standard VS Code location)
- `<project-root>/launch.json` (fallback)

Example Python launch.json:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "python",
      "request": "launch",
      "name": "Run Current File",
      "program": "${file}",
      "console": "integratedTerminal"
    }
  ]
}
```

Example C++ launch.json:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "lldb",
      "request": "launch",
      "name": "Debug executable",
      "program": "${workspaceFolder}/build/myapp",
      "args": [],
      "cwd": "${workspaceFolder}"
    }
  ]
}
```

## Telescope Integration

DAP integration with Telescope enables searching through:
- Debug configurations
- Breakpoints
- Variables
- Frames

## Troubleshooting

### Common Issues

1. **Debugger not stopping at breakpoints or breakpoints not registered in DAP**:
   - IMPORTANT: Make sure your virtual environment is activated and has debugpy installed:
     ```bash
     # Activate your virtual environment
     source .venv/bin/activate
     
     # Install debugpy in the active environment
     pip install debugpy
     ```
   - This is the most common cause of breakpoints showing visually but not working
   - Ensure the debugger is properly installed for your language
   - Check that source paths match between your code and the debugger's configuration

2. **Python debugpy not found**:
   - Run `~/dotfiles/nvim/scripts/python-debug-install.sh` to install debugpy
   - Check that the adapter path is correct in `~/.local/uv-tools/debugpy/adapter`

3. **C++ debugging not working**:
   - Ensure lldb-vscode is installed on your system
   - Check that your executable is compiled with debug symbols

4. **DAP UI not showing**:
   - Toggle it manually with `<leader>du`
   - Ensure nvim-dap-ui plugin is installed

### Setup and Verification

For Python debugging support:

```bash
# Run the Python debugging installation script
~/dotfiles/nvim/scripts/python-debug-install.sh
```

This installs:
- debugpy: Python debugger used by nvim-dap
  - Installed to `~/.local/uv-tools/debugpy`
  - The DAP configuration uses an absolute path to the debugpy adapter
- DAP plugins:
  - nvim-dap: Debug Adapter Protocol core
  - nvim-dap-ui: UI for live inspection of variables, stack, watches
  - nvim-dap-virtual-text: Inline display of variable values
  - telescope-dap: Search/navigate debug sessions