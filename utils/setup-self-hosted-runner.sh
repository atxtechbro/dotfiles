#!/bin/bash
# Setup script for GitHub Actions self-hosted runner
# For the dotfiles README memory update workflow

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}GitHub Actions Self-Hosted Runner Setup${NC}"
echo "========================================"

# Check prerequisites
check_prerequisite() {
    local cmd=$1
    local package=$2
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${RED}❌ $cmd is not installed${NC}"
        echo "   Install with: sudo apt install $package"
        return 1
    else
        echo -e "${GREEN}✓ $cmd is installed${NC}"
        return 0
    fi
}

echo -e "\n${YELLOW}Checking prerequisites...${NC}"
PREREQ_MET=true
check_prerequisite "python3" "python3" || PREREQ_MET=false
check_prerequisite "git" "git" || PREREQ_MET=false
check_prerequisite "curl" "curl" || PREREQ_MET=false

if [ "$PREREQ_MET" = false ]; then
    echo -e "\n${RED}Please install missing prerequisites before continuing${NC}"
    exit 1
fi

# Get repository information
echo -e "\n${YELLOW}Repository Configuration${NC}"
read -p "Enter your GitHub username/org (default: atxtechbro): " GITHUB_USER
GITHUB_USER=${GITHUB_USER:-atxtechbro}

read -p "Enter repository name (default: dotfiles): " REPO_NAME
REPO_NAME=${REPO_NAME:-dotfiles}

echo -e "\n${YELLOW}Runner Configuration${NC}"
read -p "Enter runner name (default: dotfiles-runner-$(hostname)): " RUNNER_NAME
RUNNER_NAME=${RUNNER_NAME:-dotfiles-runner-$(hostname)}

read -p "Enter runner work directory (default: $HOME/actions-runner): " RUNNER_DIR
RUNNER_DIR=${RUNNER_DIR:-$HOME/actions-runner}

# Create runner directory
echo -e "\n${YELLOW}Creating runner directory...${NC}"
mkdir -p "$RUNNER_DIR"
cd "$RUNNER_DIR"

# Download runner
echo -e "\n${YELLOW}Downloading GitHub Actions runner...${NC}"
RUNNER_VERSION=$(curl -s https://api.github.com/repos/actions/runner/releases/latest | grep -oE '"tag_name": "[^"]*"' | cut -d'"' -f4 | sed 's/^v//')
RUNNER_ARCH="linux-x64"

if [[ $(uname -m) == "arm"* ]] || [[ $(uname -m) == "aarch64" ]]; then
    RUNNER_ARCH="linux-arm64"
fi

DOWNLOAD_URL="https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz"

echo "Downloading runner version $RUNNER_VERSION for $RUNNER_ARCH..."
curl -o actions-runner.tar.gz -L "$DOWNLOAD_URL"

echo "Extracting runner..."
tar xzf ./actions-runner.tar.gz
rm actions-runner.tar.gz

# Get runner token
echo -e "\n${YELLOW}Authentication Required${NC}"
echo "You need to get a runner registration token from GitHub:"
echo "1. Go to: https://github.com/$GITHUB_USER/$REPO_NAME/settings/actions/runners/new"
echo "2. Copy the token from the configuration page"
echo ""
read -p "Enter the runner registration token: " RUNNER_TOKEN

# Configure runner
echo -e "\n${YELLOW}Configuring runner...${NC}"
./config.sh \
    --url "https://github.com/$GITHUB_USER/$REPO_NAME" \
    --token "$RUNNER_TOKEN" \
    --name "$RUNNER_NAME" \
    --labels "self-hosted,linux,dotfiles,python" \
    --work "_work" \
    --unattended \
    --replace

# Install as service (optional)
echo -e "\n${YELLOW}Service Installation${NC}"
read -p "Install runner as systemd service? (y/N): " INSTALL_SERVICE

if [[ "$INSTALL_SERVICE" =~ ^[Yy]$ ]]; then
    echo "Installing as service..."
    sudo ./svc.sh install
    sudo ./svc.sh start
    
    echo -e "\n${GREEN}✓ Runner installed and started as service${NC}"
    echo "Commands:"
    echo "  sudo ./svc.sh status  - Check status"
    echo "  sudo ./svc.sh stop    - Stop runner"
    echo "  sudo ./svc.sh start   - Start runner"
    echo "  journalctl -u actions.runner.$GITHUB_USER-$REPO_NAME.$RUNNER_NAME -f  - View logs"
else
    echo -e "\n${GREEN}✓ Runner configured successfully${NC}"
    echo "To run interactively: ./run.sh"
fi

# Create convenience script
cat > "$HOME/start-dotfiles-runner.sh" << EOF
#!/bin/bash
cd "$RUNNER_DIR"
./run.sh
EOF
chmod +x "$HOME/start-dotfiles-runner.sh"

echo -e "\n${GREEN}Setup Complete!${NC}"
echo "Runner location: $RUNNER_DIR"
echo "Quick start: $HOME/start-dotfiles-runner.sh"
echo ""
echo "The runner is configured with labels: self-hosted, linux, dotfiles, python"
echo "The README memory workflow will automatically use this runner."