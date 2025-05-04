# Llama.cpp related aliases
# Include this file in your .bashrc or .bash_aliases

# Set library path for llama.cpp
alias llama-env="export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/ppv/pipelines/llama.cpp/build/bin"

# Run llama.cpp models
alias llama-run="llama-run"

# Pipe content to llama.cpp
alias llama-pipe='llama-run -p "$(cat -)"'

