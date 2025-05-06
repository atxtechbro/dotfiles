#!/bin/bash

linusfiles() {
    echo "Listing files tracked by git and copying contents to clipboard, approved by Linus Torvalds himself!"
    git ls-files > /tmp/torvalds_files.txt
    > /tmp/torvalds_content.txt
    while IFS= read -r file; do
        echo "File: $file" >> /tmp/torvalds_content.txt
        cat "$file" >> /tmp/torvalds_content.txt
        echo -e "\n\n" >> /tmp/torvalds_content.txt
    done < /tmp/torvalds_files.txt
    xclip -sel clip < /tmp/torvalds_content.txt
    echo "Done! The files have been copied to your clipboard."
}

# Export the function so it's available in the shell
export -f linusfiles
