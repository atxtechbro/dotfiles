#!/bin/bash
# Google Cloud CLI (gcloud) aliases and shortcuts

# Check if gcloud is installed before defining aliases
if command -v gcloud &> /dev/null; then
    # General shortcuts
    alias gc="gcloud"
    alias gcl="gcloud config list"
    
    # Project management
    alias gcp="gcloud config set project"
    alias gcpl="gcloud projects list"
    
    # Compute Engine shortcuts
    alias gcvm="gcloud compute instances list"
    alias gcvmc="gcloud compute instances create"
    alias gcvmd="gcloud compute instances delete"
    alias gcvms="gcloud compute instances start"
    alias gcvmst="gcloud compute instances stop"
    
    # Kubernetes Engine shortcuts
    alias gck="gcloud container clusters list"
    alias gckc="gcloud container clusters create"
    alias gckd="gcloud container clusters delete"
    
    # Storage shortcuts
    alias gcs="gcloud storage ls"
    alias gcsb="gcloud storage ls gs://"
    
    # Auth shortcuts
    alias gcau="gcloud auth login"
    alias gcal="gcloud auth list"
    
    # Functions shortcuts
    alias gcf="gcloud functions list"
    alias gcfd="gcloud functions deploy"
    
    # App Engine shortcuts
    alias gcad="gcloud app deploy"
    alias gcar="gcloud app logs read"
    
    # SQL shortcuts
    alias gcsql="gcloud sql instances list"
    
    # Useful function to switch between GCP projects
    gcswitch() {
        local PROJECTS=$(gcloud projects list --format="value(projectId)" 2>/dev/null)
        
        if [ -z "$1" ]; then
            echo "Current project: $(gcloud config get-value project 2>/dev/null)"
            echo "Available projects:"
            echo "$PROJECTS" | nl
            echo "Usage: gcswitch [project_id or number]"
            return
        fi
        
        # Check if argument is a number
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            local PROJECT_LINE=$(echo "$PROJECTS" | sed -n "${1}p")
            if [ -n "$PROJECT_LINE" ]; then
                gcloud config set project "$PROJECT_LINE"
                echo "Switched to project: $PROJECT_LINE"
            else
                echo "Invalid project number. Run gcswitch without arguments to see available projects."
            fi
        else
            # Direct project ID
            if echo "$PROJECTS" | grep -q "^$1$"; then
                gcloud config set project "$1"
                echo "Switched to project: $1"
            else
                echo "Project ID not found: $1"
                echo "Run gcswitch without arguments to see available projects."
            fi
        fi
    }
    
    # SSH into an instance using just the name
    gcssh() {
        if [ -z "$1" ]; then
            echo "Usage: gcssh [instance_name]"
            gcloud compute instances list
            return
        fi
        
        gcloud compute ssh "$1" --quiet
    }
fi