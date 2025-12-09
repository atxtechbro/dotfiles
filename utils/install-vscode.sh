#!/bin/bash
# Visual Studio Code installation helper
# Spilled coffee principle: auto-heal fresh Ubuntu/apt machines when VS Code is missing

install_or_update_vscode() {
  echo "Checking Visual Studio Code..."

  if command -v code >/dev/null 2>&1; then
    echo "✓ Visual Studio Code is already installed"
    return 0
  fi

  if [[ "$OSTYPE" == "linux-gnu"* ]] && command -v apt-get >/dev/null 2>&1; then
    echo "Installing Visual Studio Code (apt-based)..."

    if ! sudo apt-get update -y >/dev/null 2>&1; then
      echo "VS Code install: failed to update package lists (check connectivity)."
      return 1
    fi

    if ! sudo apt-get install -y ca-certificates curl gnupg >/dev/null 2>&1; then
      echo "VS Code install: failed to install prerequisites."
      return 1
    fi

    sudo install -d -m 0755 /etc/apt/keyrings

    if [[ ! -f /etc/apt/keyrings/microsoft.gpg ]]; then
      if ! curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/microsoft.gpg >/dev/null; then
        echo "VS Code install: failed to download Microsoft GPG key."
        return 1
      fi
    fi

    if ! echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null; then
      echo "VS Code install: failed to add repository."
      return 1
    fi

    if ! sudo apt-get update -y >/dev/null 2>&1; then
      echo "VS Code install: failed to refresh after adding repository."
      return 1
    fi

    if sudo apt-get install -y code >/dev/null 2>&1; then
      echo "✓ Visual Studio Code installed"
      return 0
    else
      echo "VS Code install: apt install failed. Install manually or rerun setup."
      return 1
    fi
  else
    echo "Skipping Visual Studio Code installation (unsupported platform or missing apt)."
    return 0
  fi
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  install_or_update_vscode
fi
