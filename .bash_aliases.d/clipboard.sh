# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | xclip -selection clipboard'

# Quick clipboard access
alias clip="xclip -selection clipboard"

# Copy Amazon Q security recommendations to clipboard
# Works with qtrust alias in q-cli.sh for a complete security workflow
qsafe() {
    # Format as a single command with all tools on one line that updates, creates, or deletes resources
    echo "/tools untrust fs_write execute_bash use_aws \
    git___git_commit git___git_reset\
    github___create_issue github___add_issue_comment github___push_files github___create_or_update_file github___create_repository \
    github___fork_repository github___create_branch github___create_pull_request github___merge_pull_request github___create_pull_request_review github___add_pull_request_review_comment \
    gitlab___push_files gitlab___create_or_update_file gitlab___create_repository \
    atlassian___jira_create_issue atlassian___jira_update_issue atlassian___jira_add_comment atlassian___jira_add_worklog \
    atlassian___jira_create_issue_link atlassian___confluence_create_page atlassian___confluence_update_page \
    atlassian___jira_transition_issue atlassian___jira_update_sprint atlassian___jira_delete_issue \
    atlassian___confluence_delete_page atlassian___jira_remove_issue_link atlassian___confluence_add_label \
    atlassian___jira_batch_create_issues atlassian___jira_create_sprint atlassian___jira_link_to_epic" | xclip -selection clipboard
}

