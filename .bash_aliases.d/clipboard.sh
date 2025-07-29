# Clipboard management aliases
# Include this file in your .bashrc or .bash_aliases

# Source the cross-platform clipboard utility
if [[ -f "$HOME/ppv/pillars/dotfiles/utils/clipboard.sh" ]]; then
    source "$HOME/ppv/pillars/dotfiles/utils/clipboard.sh"
fi

# Copy command output to clipboard
alias clip-cmd='PREV_CMD=$(fc -ln -2 -2 | sed "s/^ *//"); (echo "Command: $PREV_CMD" && eval "$PREV_CMD" 2>&1) | clipboard_copy'

# Quick clipboard access
alias clip="clipboard_copy"

# Copy Amazon Q security recommendations to clipboard
# Works with qtrust alias in q-cli.sh for a complete security workflow
qsafe() {
    echo "/tools untrust fs_write execute_bash use_aws report_issue\
    github___create_issue\
    github___add_issue_comment\
    github___push_files\
    github___create_or_update_file\
    github___create_repository \
    github___fork_repository\
    github___create_branch\
    github___create_pull_request\
    github___merge_pull_request\
    github___create_and_submit_pull_request_review\
    github___assign_copilot_to_issue\
    github___add_pull_request_review_comment_to_pending_review\
    github___create_and_submit_pull_request_review\
    github___create_pending_pull_request_review\
    github___dismiss_notification\
    github___manage_notification_subscription\
    github___manage_repository_notification_subscription\
    github___mark_all_notifications_read\
    github___request_copilot_review\
    github___submit_pending_pull_request_review\
    github___update_issue\
    github___update_pull_request\
    github___update_pull_request_branch\
    github___run_workflow\
    github___rerun_workflow_run\
    github___rerun_failed_jobs\
    github___cancel_workflow_run\
    github___delete_workflow_run_logs\
    atlassian___jira_create_issue\
    atlassian___jira_update_issue\
    atlassian___jira_add_comment\
    atlassian___jira_add_worklog \
    atlassian___jira_create_issue_link\
    atlassian___confluence_create_page\
    atlassian___confluence_update_page \
    atlassian___confluence_add_comment
    atlassian___jira_transition_issue\
    atlassian___jira_update_sprint\
    atlassian___jira_delete_issue \
    atlassian___confluence_delete_page\
    atlassian___jira_remove_issue_link\
    atlassian___confluence_add_label \
    atlassian___jira_batch_create_issues\
    atlassian___jira_create_sprint\
    atlassian___jira_link_to_epic"\
    | clipboard_copy
}
