# GitHub Copilot Cheatsheet

A quick reference guide for GitHub Copilot integration in our Neovim configuration.

## Keybindings

| Keybinding | Description |
|------------|-------------|
| `<Tab>` | Accept suggestion |
| `<C-]>` | Next suggestion |
| `<C-[>` | Previous suggestion |
| `<leader>tc` | Toggle Copilot on/off |

## Usage Tips

- Copilot works best when you provide context through comments or partial code
- For complex suggestions, try writing a detailed comment describing what you want
- If suggestions aren't helpful, try toggling Copilot off and on again
- Copilot can complete entire functions, classes, or even files based on your comments

## Configuration

The Tab key is now configured as the primary key for accepting GitHub Copilot suggestions, while nvim-cmp functionality has been moved to the C-j key.
The configuration can be found in `nvim/lua/plugins/copilot.lua` and the completion setup in `nvim/init.lua`.