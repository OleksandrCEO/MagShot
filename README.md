# MagShot

A lightweight wrapper around **KDE Spectacle** for Wayland.

MagShot solves a common issue where web applications (like Gemini, Slack, GitHub, or some CRMs) fail to handle raw image data pasted from the clipboard. Instead of raw data, MagShot saves the screenshot to `/tmp` and copies the **file URI** to the clipboard.

This makes the browser treat the paste action as a "file upload" with a proper filename (e.g., `Screenshot_2025-01-13_12-00-00.png`), ensuring compatibility and correct file naming.

## Features

* **Region Capture:** Select an area to screenshot immediately.
* **Smart Clipboard:** Copies the file path (`file:///tmp/...`), not just the pixels.
* **Timestamped Files:** Automatically names files to avoid conflicts.
* **Temp Storage:** Keeps your main folders clean by saving to `/tmp`.

## Requirements

* Linux (Wayland)
* `spectacle` (KDE Screenshot tool)
* `wl-clipboard` (Command-line copy/paste utilities)

## Installation

### Option 1: Universal (Bash Script)

1.  Download `magshot.sh` from this repository.
2.  Make it executable and move it to your path:

    chmod +x magshot.sh
    sudo mv magshot.sh /usr/local/bin/magshot

### Option 2: NixOS Module

Import the following module into your `configuration.nix` or `home-manager` config:

    { pkgs, ... }:
    
    let
        deps = with pkgs; [
            coreutils
            kdePackages.spectacle # Use 'libsForQt5.spectacle' for Plasma 5
            wl-clipboard
        ];
    
        magshot = pkgs.writeShellScriptBin "magshot" ''
            export PATH="${pkgs.lib.makeBinPath deps}:$PATH"
            set -e
    
            # 1. Generate unique filename
            TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
            FILENAME="Screenshot_''${TIMESTAMP}.png"
            TEMP_FILE="/tmp/''${FILENAME}"
    
            # 2. Capture screenshot (Region, Background, Non-notify)
            if spectacle -r -b -n -o "$TEMP_FILE"; then
                if [ -f "$TEMP_FILE" ]; then
                    # 3. Copy file URI to clipboard
                    wl-copy --clear
                    printf "file://%s\n" "$TEMP_FILE" | wl-copy -t text/uri-list
                fi
            fi
        '';
    in
    {
        environment.systemPackages = [ magshot ];
    }

## Usage

Run the command from your terminal or bind it to a hotkey (e.g., `PrintScreen`):

    magshot

**Workflow:**
1.  The cursor changes to a crosshair.
2.  Select the region you want to capture.
3.  The screenshot is saved to `/tmp`.
4.  Paste it anywhere (Ctrl+V) — it will be pasted as a correctly named file.

## License

MIT