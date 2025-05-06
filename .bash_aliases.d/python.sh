#!/bin/bash
# Python related aliases
# Include this file in your .bashrc or .bash_aliases

# Create and activate Python virtual environment using uv
alias py-venv="[ -d .venv ] || uv venv .venv && source .venv/bin/activate"

