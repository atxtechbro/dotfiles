# Neovim Cheat Sheet

A quick reference guide for the Neovim configuration in this dotfiles repository.

## General

| Keybinding | Description |
|------------|-------------|
| `<Space>` | Leader key |
| `jk` | Exit insert mode (alternative to `<Esc>`) |
| `<leader>da` | Delete all content in current buffer |
| `<leader>cf` | Copy current filename to clipboard |
| `<leader>cp` | Copy full file path to clipboard |

## Navigation

| Keybinding | Description |
|------------|-------------|
| `gg` | Go to top of file |
| `G` | Go to bottom of file |
| `:42` or `42G` | Go to line 42 |
| `0` | Go to beginning of line |
| `$` | Go to end of line |
| `w` | Move forward one word |
| `b` | Move backward one word |
| `Ctrl+u` | Move up half a page |
| `Ctrl+d` | Move down half a page |
| `%` | Jump to matching bracket |
| `{` | Jump to previous paragraph |
| `}` | Jump to next paragraph |

## Editing

| Keybinding | Description |
|------------|-------------|
| `i` | Insert mode at cursor |
| `a` | Insert mode after cursor |
| `I` | Insert at beginning of line |
| `A` | Insert at end of line |
| `o` | Insert new line below |
| `O` | Insert new line above |
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` | Paste after cursor |
| `P` | Paste before cursor |
| `u` | Undo |
| `Ctrl+r` | Redo |

## Debugging

| Keybinding / Command | Description |
|------------|-------------|
| `<F9>` | Toggle breakpoint (VS Code style) |
| `:BreakpointToggle` | Command to toggle breakpoint (if F9 doesn't work) |
| `<leader>B` | Set conditional breakpoint |
| `<leader>lp` | Set log point |
| `<F5>` | Start/continue debugging |
| `<F10>` | Step over |
| `<F11>` | Step into |
| `<F12>` | Step out |
| `<leader>dr` | Open debug REPL |
| `<leader>du` | Toggle DAP UI |
| `<leader>db` | List breakpoints |
| `<leader>dv` | View variables |
| `<leader>df` | View stack frames |

## LSP Features

| Keybinding | Description |
|------------|-------------|
| `K` | Show hover documentation |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Show references |
| `gt` | Go to type definition |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format document |
| `[d` | Go to previous diagnostic |
| `]d` | Go to next diagnostic |
| `<leader>e` | Show diagnostics in floating window |
| `<C-h>` | Show signature help (in insert mode) |
| `<C-k>` | Toggle signature help (in insert mode) |

## Autocompletion

| Keybinding | Description |
|------------|-------------|
| `<C-Space>` | Open completion menu |
| `<C-e>` | Close completion menu |
| `<Tab>` | Select next item or expand snippet |
| `<S-Tab>` | Select previous item |
| `<CR>` | Confirm selection |
| `<C-b>` | Scroll docs up |
| `<C-f>` | Scroll docs down |

## Telescope (Fuzzy Finder)

| Keybinding | Description |
|------------|-------------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep (search in files) |
| `<leader>fb` | Browse buffers |
| `<leader>fh` | Help tags |

## Terminal

| Keybinding | Description |
|------------|-------------|
| `<leader>t` | Open terminal in horizontal split |
| `<leader>vt` | Open terminal in vertical split |

## Git Integration

| Keybinding | Description |
|------------|-------------|
| `:Gitsigns toggle_current_line_blame` | Toggle git blame |
| `:Gitsigns preview_hunk` | Preview git hunk |
| `:Gitsigns next_hunk` | Go to next git hunk |
| `:Gitsigns prev_hunk` | Go to previous git hunk |

## Workspace Management

| Keybinding | Description |
|------------|-------------|
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |

## Useful Commands

| Command | Description |
|---------|-------------|
| `:PackerSync` | Update/install plugins |
| `:Mason` | Open Mason package manager |
| `:MasonInstall <package>` | Install a language server |
| `:LspInfo` | Show LSP client information |
| `:checkhealth` | Run Neovim health check |
| `:checkhealth dap` | Check DAP configuration health |
| `:TSInstall <language>` | Install TreeSitter parser |
| `:TSUpdate` | Update TreeSitter parsers |

## Setup and Installation

To set up the LSP servers and dependencies:

```bash
# Run the LSP installation script
~/dotfiles/nvim/lsp-install.sh
```

This will install:
- Python dependencies (pyright)
- Node.js dependencies (bash-language-server, html/css/json language servers)
- Lua dependencies
- Required Neovim plugins

For Python debugging support:

```bash
# Run the Python debugging installation script
~/dotfiles/nvim/python-debug-install.sh
```

This installs:
- debugpy: Python debugger used by nvim-dap
- DAP plugins: Debug Adapter Protocol support in Neovim

## Customization

To customize the configuration, edit `~/dotfiles/nvim/init.lua`. The configuration is organized into sections:

- Basic settings
- Plugin definitions
- Keymaps
- LSP configuration
- Autocompletion setup
- TreeSitter configuration
- Git integration
