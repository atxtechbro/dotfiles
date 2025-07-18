#!/bin/bash
# Flywire-specific bash configuration
# This file is gitignored - contains company-specific details

# Work machine detection
export WORK_MACHINE="true"

# AWS Configuration - Omar's personal inference profile
export AWS_PROFILE="flywire-inference"
export BEDROCK_INFERENCE_PROFILE_ARN="arn:aws:bedrock:us-east-1:193501891505:application-inference-profile/jadcihndlp8f"

# Convenience aliases for AWS SSO
alias aws-login='aws sso login --profile flywire-inference'
alias aws-status='echo "AWS Profile: $AWS_PROFILE" && echo "Inference Profile: $BEDROCK_INFERENCE_PROFILE_ARN"'
