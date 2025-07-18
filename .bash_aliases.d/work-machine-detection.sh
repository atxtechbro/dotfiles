# Dynamic Work Machine Detection
# Automatically detect work vs personal machines based on OS
# This replaces manual WORK_MACHINE configuration with dynamic detection

# Detect if this is a work machine based on OS
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS = work machine
    export WORK_MACHINE="true"
    export MACHINE_TYPE="work"
else
    # Linux/other = personal machine  
    export WORK_MACHINE="false"
    export MACHINE_TYPE="personal"
fi

# Debug function to show detection results
work_machine_debug() {
    echo "🔍 Work Machine Detection:"
    echo "  OS: $(uname)"
    echo "  WORK_MACHINE: ${WORK_MACHINE}"
    echo "  MACHINE_TYPE: ${MACHINE_TYPE}"
    if [[ "$WORK_MACHINE" == "true" ]]; then
        echo "🏢 Work machine detected - Full MCP servers enabled"
    else
        echo "🏠 Personal machine detected - Limited MCP servers"
    fi
}
