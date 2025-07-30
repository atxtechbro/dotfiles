#!/bin/bash
# Simple benchmark to get accurate timing without parallelization issues

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=== Simple Setup Benchmark ===${NC}"
echo "Measuring actual setup times without parallelization issues"
echo ""

# Function to time a command
time_command() {
    local name="$1"
    local script="$2"
    
    echo -n "Timing $name... "
    local start_time=$(date +%s.%N)
    
    # Source the script and capture its exit status
    if (source "$script" >/dev/null 2>&1); then
        local end_time=$(date +%s.%N)
        local duration=$(echo "$end_time - $start_time" | bc)
        printf "${GREEN}%.2f seconds${NC}\n" "$duration"
        echo "$duration"
    else
        echo -e "${RED}Failed${NC}"
        echo "0"
    fi
}

# Test 1: Original setup.sh with clean state
echo -e "\n${YELLOW}Test 1: Original setup.sh (clean state)${NC}"
rm -rf ~/.dotfiles-setup-cache 2>/dev/null
ORIGINAL_TIME=$(time_command "setup.sh" "setup.sh")

# Test 2: Original setup.sh with cache (second run)
echo -e "\n${YELLOW}Test 2: Original setup.sh (cached - second run)${NC}"
ORIGINAL_CACHED=$(time_command "setup.sh (cached)" "setup.sh")

# Test 3: Individual optimized components
echo -e "\n${YELLOW}Test 3: Testing optimized components individually${NC}"
rm -rf ~/.dotfiles-setup-cache 2>/dev/null

# Test cache utils
echo -n "Testing cache-utils.sh... "
if source utils/cache-utils.sh 2>/dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}Failed${NC}"
fi

# Test fast NVM setup
echo -n "Testing fast-nvm-setup.sh... "
FAST_NVM_TIME=$(time_command "fast-nvm-setup" "utils/fast-nvm-setup.sh")

# Summary
echo -e "\n${BLUE}=== Summary ===${NC}"
echo "Original setup.sh (clean): ${ORIGINAL_TIME}s"
echo "Original setup.sh (cached): ${ORIGINAL_CACHED}s"
echo "Fast NVM component: ${FAST_NVM_TIME}s"

# Calculate improvements
if command -v bc >/dev/null 2>&1 && [[ "$ORIGINAL_TIME" != "0" ]]; then
    CACHE_IMPROVEMENT=$(echo "scale=1; (1 - $ORIGINAL_CACHED / $ORIGINAL_TIME) * 100" | bc)
    echo -e "\n${GREEN}Cache improvement: ${CACHE_IMPROVEMENT}%${NC}"
fi

echo -e "\n${YELLOW}Note: Full parallel optimization has issues that need fixing${NC}"
echo "The setup-fast.sh script needs debugging before accurate comparison"