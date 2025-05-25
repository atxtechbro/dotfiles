# GitHub Copilot Cheatsheet

A quick reference guide for GitHub Copilot integration in our Neovim configuration.

## Keybindings

| Keybinding | Description |
|------------|-------------|
| `<C-J>` | Accept suggestion |
| `<C-]>` | Next suggestion |
| `<C-[>` | Previous suggestion |
| `<leader>tc` | Toggle Copilot on/off |

## Usage Tips

- Copilot works best when you provide context through comments or partial code
- For complex suggestions, try writing a detailed comment describing what you want
- If suggestions aren't helpful, try toggling Copilot off and on again
- Copilot can complete entire functions, classes, or even files based on your comments

## Configuration

Our setup intentionally disables the default Tab key behavior to avoid conflicts with nvim-cmp.
The configuration can be found in `nvim/lua/plugins/copilot.lua`.