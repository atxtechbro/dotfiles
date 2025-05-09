alias linusfiles=\"function _linusfiles() {
    echo \"Listing files tracked by git and copying contents to clipboard, approved by Linus Torvalds himself!\";
    git ls-files > /tmp/torvalds_files.txt;
    while IFS= read -r file; do
        echo \"File: \$file\" >> /tmp/torvalds_content.txt;
        cat \"\$file\" >> /tmp/torvalds_content.txt;
        echo -e \"\\n\\n\" >> /tmp/torvalds_content.txt;
    done < /tmp/torvalds_files.txt;
    xclip -sel clip < /tmp/torvalds_content.txt;
    echo \"Done! The files have been copied to your clipboard.\";
}; _linusfiles\"