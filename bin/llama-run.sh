#!/bin/bash
# llama-run: A simple CLI wrapper for llama.cpp with defaults set

MODEL="${LLAMA_MODEL:-$HOME/ppv/pipelines/models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf}"
BINARY="$HOME/ppv/pipelines/llama.cpp/build/bin/llama-cli"

exec "$BINARY" -no-cnv --simple-io -m "$MODEL" -p "$*"

