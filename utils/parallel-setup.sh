#!/bin/bash
# Parallel execution framework for dotfiles setup
# Enables concurrent execution of independent setup tasks

# Array to track background jobs
declare -a PARALLEL_JOBS=()
declare -a PARALLEL_JOB_NAMES=()
declare -a PARALLEL_JOB_LOGS=()

# Temporary directory for job logs
PARALLEL_LOG_DIR="/tmp/dotfiles-setup-$$"
mkdir -p "$PARALLEL_LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Start a parallel job
start_parallel_job() {
    local job_name="$1"
    shift
    local command=("$@")
    
    local log_file="$PARALLEL_LOG_DIR/${job_name}.log"
    
    echo -e "${BLUE}→ Starting parallel job: $job_name${NC}"
    
    # Run command in background, capturing output
    (
        echo "=== Job: $job_name ===" > "$log_file"
        echo "Started: $(date)" >> "$log_file"
        echo "Command: ${command[*]}" >> "$log_file"
        echo "" >> "$log_file"
        
        # Execute command and capture exit code
        if "${command[@]}" >> "$log_file" 2>&1; then
            echo "" >> "$log_file"
            echo "Completed successfully: $(date)" >> "$log_file"
            echo "SUCCESS:$job_name" > "$log_file.status"
        else
            local exit_code=$?
            echo "" >> "$log_file"
            echo "Failed with exit code $exit_code: $(date)" >> "$log_file"
            echo "FAILED:$job_name:$exit_code" > "$log_file.status"
        fi
    ) &
    
    local job_pid=$!
    PARALLEL_JOBS+=($job_pid)
    PARALLEL_JOB_NAMES+=("$job_name")
    PARALLEL_JOB_LOGS+=("$log_file")
}

# Wait for all parallel jobs to complete
wait_parallel_jobs() {
    local failed_jobs=()
    local successful_jobs=()
    
    if [[ ${#PARALLEL_JOBS[@]} -eq 0 ]]; then
        return 0
    fi
    
    echo -e "\n${BLUE}⏳ Waiting for ${#PARALLEL_JOBS[@]} parallel jobs to complete...${NC}"
    
    # Show progress indicator
    local i=0
    while [[ ${#PARALLEL_JOBS[@]} -gt 0 ]]; do
        local remaining_jobs=()
        local remaining_names=()
        local remaining_logs=()
        
        for idx in "${!PARALLEL_JOBS[@]}"; do
            local pid=${PARALLEL_JOBS[$idx]}
            local name=${PARALLEL_JOB_NAMES[$idx]}
            local log=${PARALLEL_JOB_LOGS[$idx]}
            
            if kill -0 "$pid" 2>/dev/null; then
                # Job still running
                remaining_jobs+=($pid)
                remaining_names+=("$name")
                remaining_logs+=("$log")
            else
                # Job completed
                wait "$pid"
                local exit_code=$?
                
                if [[ -f "$log.status" ]]; then
                    local status=$(cat "$log.status")
                    if [[ $status == SUCCESS:* ]]; then
                        successful_jobs+=("$name")
                        echo -e "\n${GREEN}✓ Completed: $name${NC}"
                    else
                        failed_jobs+=("$name")
                        echo -e "\n${RED}✗ Failed: $name${NC}"
                        # Show last 5 lines of error log
                        echo -e "${YELLOW}Last 5 lines from log:${NC}"
                        tail -5 "$log" | sed 's/^/  /'
                    fi
                fi
            fi
        done
        
        PARALLEL_JOBS=("${remaining_jobs[@]}")
        PARALLEL_JOB_NAMES=("${remaining_names[@]}")
        PARALLEL_JOB_LOGS=("${remaining_logs[@]}")
        
        if [[ ${#PARALLEL_JOBS[@]} -gt 0 ]]; then
            # Show spinner
            local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
            printf "\r${BLUE}%s${NC} Waiting for %d jobs: %s" \
                "${spinner:i++%${#spinner}:1}" \
                "${#PARALLEL_JOBS[@]}" \
                "$(IFS=', '; echo "${PARALLEL_JOB_NAMES[*]}")"
            sleep 0.1
        fi
    done
    
    printf "\r%*s\r" 80 ""  # Clear the progress line
    
    # Summary
    echo -e "\n${BLUE}=== Parallel Job Summary ===${NC}"
    if [[ ${#successful_jobs[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Successful (${#successful_jobs[@]}):${NC} ${successful_jobs[*]}"
    fi
    if [[ ${#failed_jobs[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Failed (${#failed_jobs[@]}):${NC} ${failed_jobs[*]}"
        echo -e "${YELLOW}Check logs in: $PARALLEL_LOG_DIR${NC}"
        return 1
    fi
    
    # Clean up logs if all successful
    rm -rf "$PARALLEL_LOG_DIR"
    return 0
}

# Execute multiple commands in parallel
parallel_execute() {
    local -n job_array=$1
    
    for job in "${job_array[@]}"; do
        # Parse job format: "name:command"
        local job_name="${job%%:*}"
        local job_command="${job#*:}"
        
        start_parallel_job "$job_name" bash -c "$job_command"
    done
    
    wait_parallel_jobs
}

# Group execution helper - runs groups sequentially, jobs within groups in parallel
execute_setup_groups() {
    local group_num=1
    
    for group_name in "$@"; do
        local -n group=$group_name
        
        echo -e "\n${BLUE}=== Setup Group $group_num: $group_name ===${NC}"
        
        for job in "${group[@]}"; do
            local job_name="${job%%:*}"
            local job_command="${job#*:}"
            start_parallel_job "$job_name" bash -c "$job_command"
        done
        
        if ! wait_parallel_jobs; then
            echo -e "${RED}Group $group_name failed. Stopping execution.${NC}"
            return 1
        fi
        
        ((group_num++))
    done
    
    return 0
}

# Cleanup function
cleanup_parallel_logs() {
    rm -rf "$PARALLEL_LOG_DIR"
}

# Set trap to cleanup on exit
trap cleanup_parallel_logs EXIT

# Export functions
export -f start_parallel_job
export -f wait_parallel_jobs
export -f parallel_execute
export -f execute_setup_groups