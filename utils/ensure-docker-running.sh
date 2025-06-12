#!/bin/bash

# =========================================================
# DOCKER MANAGEMENT UTILITY
# =========================================================
# PURPOSE: Ensure Docker is running before proceeding
# Handles Docker Desktop startup automatically
# Following the "Spilled Coffee Principle" - no manual steps
# =========================================================

set -e

# Define colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Checking Docker status...${NC}"

# Function to check if Docker daemon is running
is_docker_running() {
    docker info >/dev/null 2>&1
}

# Function to start Docker Desktop on macOS
start_docker_macos() {
    echo -e "${YELLOW}Starting Docker Desktop...${NC}"
    open -a Docker
    
    # Wait for Docker to start (up to 60 seconds)
    echo -e "${BLUE}Waiting for Docker to start...${NC}"
    for i in {1..60}; do
        if is_docker_running; then
            echo -e "${GREEN}✓ Docker is now running${NC}"
echo -e "${BLUE}Docker is ready! You can now continue with your setup.${NC}"
echo -e "${GREEN}Next: Re-run your original command to continue${NC}"            return 0
        fi
        echo -n "."
        sleep 1
    done
    
    echo -e "\n${RED}Docker failed to start within 60 seconds${NC}"
    return 1
}

# Function to start Docker on Linux
start_docker_linux() {
    echo -e "${YELLOW}Starting Docker service...${NC}"
    
    # Try systemctl first (most common)
    if command -v systemctl >/dev/null 2>&1; then
        sudo systemctl start docker
        sudo systemctl enable docker
    # Try service command as fallback
    elif command -v service >/dev/null 2>&1; then
        sudo service docker start
    else
        echo -e "${RED}Cannot start Docker - no systemctl or service command found${NC}"
        return 1
    fi
    
    # Wait for Docker to be ready
    for i in {1..30}; do
        if is_docker_running; then
            echo -e "${GREEN}✓ Docker is now running${NC}"
echo -e "${BLUE}Docker is ready! You can now continue with your setup.${NC}"
echo -e "${GREEN}Next: Re-run your original command to continue${NC}"            return 0
        fi
        sleep 1
    done
    
    echo -e "${RED}Docker failed to start${NC}"
    return 1
}

# Main logic
if is_docker_running; then
    echo -e "${GREEN}✓ Docker is already running${NC}"
    exit 0
fi

echo -e "${YELLOW}Docker is not running${NC}"

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Docker is not installed${NC}"
    echo "Please install Docker:"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  brew install --cask docker"
        echo "  Or download from: https://www.docker.com/products/docker-desktop"
    else
        echo "  Visit: https://docs.docker.com/engine/install/"
    fi
    exit 1
fi

# Start Docker based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    start_docker_macos
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    start_docker_linux
else
    echo -e "${RED}Unsupported OS for automatic Docker startup: $OSTYPE${NC}"
    echo "Please start Docker manually and run this script again"
    exit 1
fi
