#!/bin/bash

# Get the basename of the current working directory
CURRENT_DIR=$(basename "$PWD")

# Find the VS Code window that contains the current directory name
WINDOW_ID=$(wmctrl -l | grep -i "Visual Studio Code" | grep -i "$CURRENT_DIR" | head -1 | awk '{print $1}')

if [ -n "$WINDOW_ID" ]; then
    # Set urgency hint on the matching window
    wmctrl -i -b add,demands_attention -r "$WINDOW_ID"
fi
