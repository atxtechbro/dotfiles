#!/bin/bash

# =========================================================
# OAUTH HELPER UTILITIES
# =========================================================
# PURPOSE: Reusable OAuth functions for Google services
# Following the "Snowball Method" - build reusable components
# =========================================================

# Generate OAuth URL for Google services
generate_google_oauth_url() {
    local client_id="$1"
    local scope="$2"
    local redirect_uri="${3:-http://localhost}"
    
    echo "https://accounts.google.com/o/oauth2/auth?client_id=${client_id}&redirect_uri=${redirect_uri}&scope=${scope}&response_type=code&access_type=offline&prompt=consent"
}

# Extract authorization code from callback URL
extract_auth_code() {
    local callback_url="$1"
    echo "$callback_url" | sed -n 's/.*code=\([^&]*\).*/\1/p'
}

# Exchange authorization code for tokens
exchange_auth_code() {
    local client_id="$1"
    local client_secret="$2"
    local auth_code="$3"
    local redirect_uri="${4:-http://localhost}"
    
    curl -s -X POST https://oauth2.googleapis.com/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=$client_id" \
      -d "client_secret=$client_secret" \
      -d "code=$auth_code" \
      -d "grant_type=authorization_code" \
      -d "redirect_uri=$redirect_uri"
}

# Validate that jq is available
require_jq() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed"
        echo "Install with: brew install jq"
        exit 1
    fi
}
