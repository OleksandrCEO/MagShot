#!/usr/bin/env bash

# MagShot - A wrapper for Spectacle to copy screenshots as files to clipboard (Wayland)
# Dependencies: spectacle, wl-clipboard

set -e

# --- Check Dependencies ---
if ! command -v spectacle &> /dev/null; then
    echo "Error: 'spectacle' is not installed."
    exit 1
fi

if ! command -v wl-copy &> /dev/null; then
    echo "Error: 'wl-clipboard' is not installed."
    exit 1
fi

# --- Main Logic ---

# 1. Generate unique filename
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
FILENAME="Screenshot_${TIMESTAMP}.png"
TEMP_FILE="/tmp/${FILENAME}"

# 2. Capture screenshot
# -r: Region selection
# -b: Background mode (no GUI)
# -n: Non-notifying
# -o: Output to file
spectacle -r -b -n -o "$TEMP_FILE"

# 3. Process to Clipboard
# We check if the file exists because the user might have cancelled the selection (Esc)
if [ -f "$TEMP_FILE" ]; then
    # Clear clipboard
    wl-copy --clear

    # Copy as file URI (MIME: text/uri-list)
    # This allows pasting directly into file inputs in browsers (e.g. Gmail, Slack, GitHub)
    printf "file://%s\n" "$TEMP_FILE" | wl-copy -t text/uri-list
fi