#!/bin/bash
# Build Amazon Q CLI from source
# This script builds Amazon Q CLI from source and sets it up for use
# Following the "spilled coffee principle" - anyone should be able to destroy their machine
# and be fully operational again that afternoon

set -e

# Define colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
DIVIDER="----------------------------------------"

# Define paths
DOT_DEN="${DOT_DEN:-$HOME/ppv/pillars/dotfiles}"
REPO_DIR="$HOME/ppv/pillars/amazon-q-developer-cli"
INSTALL_DIR="$HOME/.local/bin"
BACKUP_DIR="$HOME/.amazon-q-backup-$(date +%Y%m%d%H%M%S)"

# Parse command line arguments
FORCE_REBUILD=false
SKIP_DEPS=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --force|-f) FORCE_REBUILD=true ;;
        --skip-deps) SKIP_DEPS=true ;;
        --help|-h) 
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --force, -f     Force rebuild even if q is already installed"
            echo "  --skip-deps     Skip dependency installation"
            echo "  --help, -h      Show this help message"
            exit 0
            ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Check if q is already installed and not forcing rebuild
if command -v q &> /dev/null && [ "$FORCE_REBUILD" = false ]; then
    echo -e "${YELLOW}Amazon Q CLI is already installed.${NC}"
    echo -e "To force a rebuild, run with --force or -f flag."
    echo -e "Current version: $(q --version 2>/dev/null || echo 'Unknown')"
    exit 0
fi

# Create directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$BACKUP_DIR"

# Ensure install directory is in PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo -e "${YELLOW}Adding $INSTALL_DIR to PATH${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$INSTALL_DIR:$PATH"
fi

# Backup existing q binary if it exists
if command -v q &> /dev/null; then
    Q_PATH=$(which q)
    echo -e "${BLUE}Backing up existing q binary from $Q_PATH${NC}"
    cp "$Q_PATH" "$BACKUP_DIR/q.backup"
fi

# Install dependencies if not skipped
if [ "$SKIP_DEPS" = false ]; then
    echo -e "${DIVIDER}"
    echo -e "${BLUE}Installing dependencies...${NC}"
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Detect package manager
        if command -v apt &> /dev/null; then
            echo "Installing dependencies with apt..."
            sudo apt update
            sudo apt install -y build-essential pkg-config jq dpkg curl wget zstd cmake clang \
                libssl-dev libgtk-3-dev libwebkit2gtk-4.0-dev libappindicator3-dev \
                librsvg2-dev patchelf
        elif command -v pacman &> /dev/null; then
            echo "Installing dependencies with pacman..."
            sudo pacman -Sy --noconfirm base-devel pkg-config jq curl wget zstd cmake clang \
                openssl gtk3 webkit2gtk libappindicator-gtk3 librsvg patchelf
        elif command -v dnf &> /dev/null; then
            echo "Installing dependencies with dnf..."
            sudo dnf install -y gcc gcc-c++ make pkg-config jq dpkg curl wget zstd cmake clang \
                openssl-devel gtk3-devel webkit2gtk3-devel libappindicator-gtk3 librsvg2-devel patchelf
        else
            echo -e "${YELLOW}Unsupported package manager. Please install dependencies manually:${NC}"
            echo "build-essential pkg-config jq dpkg curl wget zstd cmake clang libssl-dev libgtk-3-dev"
            echo "libwebkit2gtk-4.0-dev libappindicator3-dev librsvg2-dev patchelf"
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing dependencies with Homebrew..."
            brew install protobuf fish shellcheck
        else
            echo -e "${YELLOW}Homebrew not found. Please install Homebrew first:${NC}"
            echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            read -p "Continue anyway? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        echo -e "${RED}Unsupported OS: $OSTYPE${NC}"
        exit 1
    fi
    
    # Install Rust if not already installed
    if ! command -v rustup &> /dev/null; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        source "$HOME/.cargo/env"
    else
        echo "Rust is already installed. Updating..."
        rustup update
    fi
    
    # Install required Rust components
    rustup component add rustfmt clippy
    
    echo -e "${GREEN}✓ Dependencies installed${NC}"
fi

# Clone or update repository
echo -e "${DIVIDER}"
echo -e "${BLUE}Setting up repository...${NC}"

if [ -d "$REPO_DIR" ]; then
    echo "Repository already exists. Updating..."
    cd "$REPO_DIR"
    git fetch
    git checkout main
    git pull
else
    echo "Cloning repository..."
    mkdir -p "$(dirname "$REPO_DIR")"
    git clone https://github.com/atxtechbro/amazon-q-developer-cli.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

# Build Amazon Q CLI
echo -e "${DIVIDER}"
echo -e "${BLUE}Building Amazon Q CLI...${NC}"
echo "This may take a few minutes..."

# Get version before build
VERSION=$(grep -A 1 '^\[package\]' crates/cli/Cargo.toml | grep 'version' | cut -d '"' -f2)
echo "Building version: $VERSION"

# Build with cargo
cargo build --release

# Install binary
echo -e "${DIVIDER}"
echo -e "${BLUE}Installing Amazon Q CLI...${NC}"

cp target/release/q "$INSTALL_DIR/q-custom"

# Create wrapper script
cat > "$INSTALL_DIR/q" << 'EOF'
#!/bin/bash
# Wrapper script for custom Amazon Q CLI build
exec "$HOME/.local/bin/q-custom" "$@"
EOF
chmod +x "$INSTALL_DIR/q"

# Verify installation
echo -e "${DIVIDER}"
echo -e "${BLUE}Verifying installation...${NC}"

if command -v q &> /dev/null; then
    INSTALLED_VERSION=$(q --version 2>/dev/null || echo "Unknown")
    echo -e "${GREEN}✓ Amazon Q CLI successfully built and installed!${NC}"
    echo -e "Version: $INSTALLED_VERSION"
    echo -e "Binary location: $(which q)"
    echo -e "Custom binary: $INSTALL_DIR/q-custom"
else
    echo -e "${RED}Installation verification failed.${NC}"
    echo "Please check if $INSTALL_DIR is in your PATH."
    exit 1
fi

# Create restoration script
cat > "$BACKUP_DIR/restore.sh" << EOF
#!/bin/bash
# Restoration script for Amazon Q CLI
echo "Restoring Amazon Q CLI from backup..."
if [ -f "$BACKUP_DIR/q.backup" ]; then
    cp "$BACKUP_DIR/q.backup" "$INSTALL_DIR/q"
    chmod +x "$INSTALL_DIR/q"
    echo "Restored successfully!"
else
    echo "No backup found at $BACKUP_DIR/q.backup"
fi
EOF
chmod +x "$BACKUP_DIR/restore.sh"

echo -e "${DIVIDER}"
echo -e "${GREEN}✅ Amazon Q CLI build complete!${NC}"
echo -e "To restore the previous version, run: $BACKUP_DIR/restore.sh"
echo -e "${DIVIDER}"
