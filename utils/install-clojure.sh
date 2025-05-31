#!/bin/bash
# install-clojure.sh - Automated Clojure installation script
# Following the "spilled coffee principle" - ensuring reproducible setup

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define paths
DOTFILES_DIR="$HOME/ppv/pillars/dotfiles"

echo -e "${BLUE}=== Clojure Installation Script ===${NC}"
echo -e "${BLUE}This script installs Clojure and sets up necessary environment.${NC}"
echo -e "${BLUE}Following the \"spilled coffee principle\" for quick environment restoration.${NC}"
echo -e "${BLUE}=================================================${NC}\n"

# Detect operating system
detect_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      OS=$NAME
      if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]] || [[ "$OS" == *"Mint"* ]]; then
        echo "debian"
      elif [[ "$OS" == *"Fedora"* ]] || [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
        echo "fedora"
      elif [[ "$OS" == *"Arch"* ]] || [[ "$OS" == *"Manjaro"* ]]; then
        echo "arch"
      else
        echo "unknown_linux"
      fi
    else
      echo "unknown_linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo "macos"
  else
    echo "unknown"
  fi
}

# Check if Java is installed
check_java() {
  if ! command -v java &> /dev/null; then
    echo -e "${YELLOW}Java is required for Clojure but not installed.${NC}"
    
    # Check if we have the Java installation script
    if [ -f "$DOTFILES_DIR/utils/install-java.sh" ]; then
      echo -e "${YELLOW}Installing Java using the automated script...${NC}"
      bash "$DOTFILES_DIR/utils/install-java.sh"
      
      # Check if installation was successful
      if ! command -v java &> /dev/null; then
        echo -e "${RED}Error: Java installation failed.${NC}"
        echo -e "Clojure requires Java to run. Please install Java first."
        exit 1
      fi
    else
      echo -e "${RED}Error: Java is required but not installed.${NC}"
      echo -e "Clojure requires Java to run. Please install Java first."
      exit 1
    fi
  else
    echo -e "${GREEN}Java is already installed.${NC}"
  fi
}

# Check if Clojure is already installed
check_clojure() {
  if command -v clojure &> /dev/null; then
    local clj_version=$(clojure -e '(clojure-version)' 2>&1 | tr -d '"')
    echo -e "${GREEN}Clojure is already installed (version $clj_version)${NC}"
    return 0
  else
    echo -e "${YELLOW}Clojure is not installed${NC}"
    return 1
  fi
}

# Install Clojure on Debian-based systems (Ubuntu, Debian, Mint)
install_clojure_debian() {
  echo -e "${YELLOW}Installing Clojure on Debian-based system...${NC}"
  
  # Install dependencies
  sudo apt update
  sudo apt install -y curl rlwrap
  
  # Install Clojure
  curl -O https://download.clojure.org/install/linux-install-1.11.1.1273.sh
  chmod +x linux-install-1.11.1.1273.sh
  sudo ./linux-install-1.11.1.1273.sh
  rm linux-install-1.11.1.1273.sh
}

# Install Clojure on Fedora-based systems (Fedora, CentOS, RHEL)
install_clojure_fedora() {
  echo -e "${YELLOW}Installing Clojure on Fedora-based system...${NC}"
  
  # Install Clojure
  sudo dnf install -y clojure
}

# Install Clojure on Arch-based systems (Arch Linux, Manjaro)
install_clojure_arch() {
  echo -e "${YELLOW}Installing Clojure on Arch-based system...${NC}"
  
  # Install Clojure
  sudo pacman -S --noconfirm clojure
}

# Install Clojure on macOS
install_clojure_macos() {
  echo -e "${YELLOW}Installing Clojure on macOS...${NC}"
  
  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  # Install Clojure
  brew install clojure/tools/clojure
}

# Manual installation for unsupported systems
install_clojure_manual() {
  echo -e "${YELLOW}Your system is not directly supported. Attempting manual installation...${NC}"
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  # Download and install Clojure
  echo -e "${YELLOW}Downloading Clojure...${NC}"
  curl -O https://download.clojure.org/install/linux-install-1.11.1.1273.sh
  chmod +x linux-install-1.11.1.1273.sh
  
  # Try to install
  if sudo ./linux-install-1.11.1.1273.sh; then
    echo -e "${GREEN}Clojure installed successfully.${NC}"
  else
    echo -e "${RED}Failed to install Clojure automatically.${NC}"
    echo -e "${YELLOW}Attempting to install to user directory...${NC}"
    
    # Create user bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Install to user directory
    ./linux-install-1.11.1.1273.sh --prefix "$HOME/.local"
    
    # Add to PATH if not already there
    if ! grep -q "$HOME/.local/bin" "$HOME/.bashrc"; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
      echo -e "${YELLOW}Added $HOME/.local/bin to PATH in .bashrc${NC}"
    fi
  fi
  
  # Clean up
  cd "$OLDPWD"
  rm -rf "$temp_dir"
}

# Display Clojure information
show_clojure_info() {
  echo -e "\n${BLUE}=== Clojure Information ===${NC}"
  echo -e "${BLUE}Clojure Version:${NC} $(clojure -e '(clojure-version)' 2>&1 | tr -d '"')"
  echo -e "${BLUE}Clojure CLI Version:${NC} $(clojure -Sdescribe | grep version | head -n 1)"
  echo -e "${BLUE}Java Version:${NC} $(java -version 2>&1 | head -n 1)"
  echo -e "${BLUE}=================================================${NC}\n"
}

# Main installation process
main() {
  # Check if Java is installed (required for Clojure)
  check_java
  
  # Check if Clojure is already installed
  if check_clojure; then
    echo -e "${GREEN}Clojure is already installed. No need to install.${NC}"
  else
    # Detect OS and install Clojure
    local os_type=$(detect_os)
    
    case "$os_type" in
      "debian")
        install_clojure_debian
        ;;
      "fedora")
        install_clojure_fedora
        ;;
      "arch")
        install_clojure_arch
        ;;
      "macos")
        install_clojure_macos
        ;;
      *)
        install_clojure_manual
        ;;
    esac
  fi
  
  # Show Clojure information
  show_clojure_info
  
  echo -e "\n${GREEN}Clojure installation and setup completed successfully!${NC}"
  
  # Display educational information about Clojure and REPL
  echo -e "\n${BLUE}=== About Clojure and REPL-Driven Development ===${NC}"
  echo -e "Clojure is a dynamic, functional Lisp dialect that runs on the Java Virtual Machine."
  echo -e "It emphasizes immutability, which makes it ideal for concurrent programming."
  echo -e "\nREPL-Driven Development is a powerful workflow where you:"
  echo -e "- Evaluate code incrementally as you write it"
  echo -e "- Maintain state between evaluations"
  echo -e "- Explore and test ideas interactively"
  echo -e "- Build solutions piece by piece"
  echo -e "\nThis workflow exemplifies the \"Snowball Method\" principle, where each"
  echo -e "development session builds on the accumulated knowledge of previous sessions,"
  echo -e "creating a virtuous cycle of continuous improvement."
  echo -e "\nTo learn more about Clojure and REPL-Driven Development, visit:"
  echo -e "- https://clojure.org/guides/repl/introduction"
  echo -e "- https://clojure.org/reference/repl_and_main"
  echo -e "${BLUE}=================================================${NC}\n"
}

# Execute main function
main

exit 0
