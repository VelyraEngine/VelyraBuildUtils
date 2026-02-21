#!/bin/bash

# Loop through all subdirectories
for dir in */ ; do
    # Check if it's a directory
    if [ -d "$dir" ]; then
        echo "Entering $dir"
        cd "$dir"

        # Check if it's a git repository
        if [ -d ".git" ]; then
            echo " -> Running git pull..."
            git pull
        else
            echo " -> Not a git repository, skipping."
        fi

        # Go back to the parent directory
        cd ..
        echo
    fi
done

echo "All done!"
