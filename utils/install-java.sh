#!/bin/bash
# install-java.sh - Automated Java installation script
# Following the "spilled coffee principle" - ensuring reproducible setup

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default Java version (LTS)
DEFAULT_JAVA_VERSION="17"
JAVA_VERSION=${1:-$DEFAULT_JAVA_VERSION}

echo -e "${BLUE}=== Java Installation Script ===${NC}"
echo -e "${BLUE}This script installs Java and sets up necessary environment variables.${NC}"
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

# Check if Java is already installed
check_java() {
  if command -v java &> /dev/null; then
    local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo -e "${GREEN}Java is already installed (version $java_version)${NC}"
    return 0
  else
    echo -e "${YELLOW}Java is not installed${NC}"
    return 1
  fi
}

# Install Java on Debian-based systems (Ubuntu, Debian, Mint)
install_java_debian() {
  echo -e "${YELLOW}Installing Java on Debian-based system...${NC}"
  
  # Update package lists
  sudo apt update
  
  # Install Java
  if [ "$JAVA_VERSION" == "8" ]; then
    sudo apt install -y openjdk-8-jdk
  elif [ "$JAVA_VERSION" == "11" ]; then
    sudo apt install -y openjdk-11-jdk
  elif [ "$JAVA_VERSION" == "17" ]; then
    sudo apt install -y openjdk-17-jdk
  else
    sudo apt install -y openjdk-17-jdk
    echo -e "${YELLOW}Requested Java version $JAVA_VERSION not available, installed Java 17 instead${NC}"
  fi
  
  # Verify installation
  java -version
}

# Install Java on Fedora-based systems (Fedora, CentOS, RHEL)
install_java_fedora() {
  echo -e "${YELLOW}Installing Java on Fedora-based system...${NC}"
  
  # Install Java
  if [ "$JAVA_VERSION" == "8" ]; then
    sudo dnf install -y java-1.8.0-openjdk-devel
  elif [ "$JAVA_VERSION" == "11" ]; then
    sudo dnf install -y java-11-openjdk-devel
  elif [ "$JAVA_VERSION" == "17" ]; then
    sudo dnf install -y java-17-openjdk-devel
  else
    sudo dnf install -y java-17-openjdk-devel
    echo -e "${YELLOW}Requested Java version $JAVA_VERSION not available, installed Java 17 instead${NC}"
  fi
  
  # Verify installation
  java -version
}

# Install Java on Arch-based systems (Arch Linux, Manjaro)
install_java_arch() {
  echo -e "${YELLOW}Installing Java on Arch-based system...${NC}"
  
  # Update package database
  sudo pacman -Sy
  
  # Install Java
  if [ "$JAVA_VERSION" == "8" ]; then
    sudo pacman -S --noconfirm jdk8-openjdk
  elif [ "$JAVA_VERSION" == "11" ]; then
    sudo pacman -S --noconfirm jdk11-openjdk
  elif [ "$JAVA_VERSION" == "17" ]; then
    sudo pacman -S --noconfirm jdk17-openjdk
  else
    sudo pacman -S --noconfirm jdk17-openjdk
    echo -e "${YELLOW}Requested Java version $JAVA_VERSION not available, installed Java 17 instead${NC}"
  fi
  
  # Verify installation
  java -version
}

# Install Java on macOS
install_java_macos() {
  echo -e "${YELLOW}Installing Java on macOS...${NC}"
  
  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing Homebrew...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  # Install Java
  if [ "$JAVA_VERSION" == "8" ]; then
    brew install --cask adoptopenjdk8
  elif [ "$JAVA_VERSION" == "11" ]; then
    brew install --cask adoptopenjdk11
  elif [ "$JAVA_VERSION" == "17" ]; then
    brew install --cask temurin17
  else
    brew install --cask temurin17
    echo -e "${YELLOW}Requested Java version $JAVA_VERSION not available, installed Java 17 instead${NC}"
  fi
  
  # Verify installation
  java -version
}

# Manual installation for unsupported systems
install_java_manual() {
  echo -e "${YELLOW}Your system is not directly supported. Attempting manual installation...${NC}"
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  # Download and install AdoptOpenJDK
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo -e "${YELLOW}Downloading AdoptOpenJDK for Linux...${NC}"
    curl -L -o java.tar.gz "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.7%2B7/OpenJDK17U-jdk_x64_linux_hotspot_17.0.7_7.tar.gz"
    
    # Extract
    mkdir -p "$HOME/.jdk"
    tar -xzf java.tar.gz -C "$HOME/.jdk" --strip-components=1
    
    # Set up environment variables
    echo 'export JAVA_HOME="$HOME/.jdk"' >> "$HOME/.bashrc"
    echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> "$HOME/.bashrc"
    
    # Source bashrc
    source "$HOME/.bashrc"
  else
    echo -e "${RED}Manual installation not supported for your OS${NC}"
    exit 1
  fi
  
  # Clean up
  cd "$OLDPWD"
  rm -rf "$temp_dir"
  
  echo -e "${GREEN}Manual installation completed. Please restart your terminal.${NC}"
}

# Set up environment variables
setup_environment() {
  echo -e "${YELLOW}Setting up environment variables...${NC}"
  
  # Find Java home
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    JAVA_HOME=$(/usr/libexec/java_home)
  fi
  
  # Check if JAVA_HOME is already in .bashrc
  if ! grep -q "JAVA_HOME" "$HOME/.bashrc"; then
    echo -e "\n# Java environment variables" >> "$HOME/.bashrc"
    echo "export JAVA_HOME=\"$JAVA_HOME\"" >> "$HOME/.bashrc"
    echo "export PATH=\"\$JAVA_HOME/bin:\$PATH\"" >> "$HOME/.bashrc"
  fi
  
  echo -e "${GREEN}Environment variables set up. JAVA_HOME=$JAVA_HOME${NC}"
}

# Note: Clojure installation functionality has been removed
# as part of the subtraction creates value initiative (Issue #482)

# Display JVM information
show_jvm_info() {
  echo -e "\n${BLUE}=== JVM Information ===${NC}"
  echo -e "${BLUE}Java Version:${NC} $(java -version 2>&1 | head -n 1)"
  echo -e "${BLUE}Java Home:${NC} $JAVA_HOME"
  echo -e "${BLUE}JVM Architecture:${NC} $(java -XshowSettings:properties -version 2>&1 | grep sun.arch.data.model)"
  echo -e "${BLUE}JVM Memory:${NC} $(java -XX:+PrintFlagsFinal -version 2>&1 | grep -i MaxHeapSize | awk '{print $4}')"
  echo -e "${BLUE}=================================================${NC}\n"
}

# Main installation process
main() {
  # Check if Java is already installed
  if check_java; then
    echo -e "${GREEN}Java is already installed. No need to install.${NC}"
  else
    # Detect OS and install Java
    local os_type=$(detect_os)
    
    case "$os_type" in
      "debian")
        install_java_debian
        ;;
      "fedora")
        install_java_fedora
        ;;
      "arch")
        install_java_arch
        ;;
      "macos")
        install_java_macos
        ;;
      *)
        install_java_manual
        ;;
    esac
  fi
  
  # Set up environment variables
  setup_environment
  
  # Show JVM information
  show_jvm_info
  
  # Note: Clojure installation functionality has been removed
  # as part of the subtraction creates value initiative (Issue #482)
  
  echo -e "\n${GREEN}Java installation and setup completed successfully!${NC}"
  echo -e "${YELLOW}You may need to restart your terminal for all changes to take effect.${NC}"
  
  # Display educational information about JVM
  echo -e "\n${BLUE}=== About the JVM ===${NC}"
  echo -e "The Java Virtual Machine (JVM) is a crucial component that enables Java's"
  echo -e "\"write once, run anywhere\" capability. It provides:"
  echo -e "- Platform independence through bytecode execution"
  echo -e "- Automatic memory management with garbage collection"
  echo -e "- Just-In-Time (JIT) compilation for performance optimization"
  echo -e "- Dynamic class loading for runtime code evaluation"
  echo -e "- Security features through the sandbox model"
  echo -e "\nThese features make the JVM an excellent platform for many languages,"
  echo -e "which leverage its capabilities for REPL-driven development and interactive"
  echo -e "programming workflows."
  echo -e "\nTo learn more about the JVM, visit:"
  echo -e "- https://blog.jamesdbloom.com/JVMInternals.html"
  echo -e "${BLUE}=================================================${NC}\n"
}

# Execute main function
main

exit 0
