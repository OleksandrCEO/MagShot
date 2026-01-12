{ pkgs, ... }:

let
  # Define dependencies
  deps = with pkgs; [
    coreutils    # date
    kdePackages.spectacle # Screenshot tool (KDE Plasma 6)
    wl-clipboard # Clipboard manager for Wayland
  ];

  magshot = pkgs.writeShellScriptBin "magshot" ''
    export PATH="${pkgs.lib.makeBinPath deps}:$PATH"
    set -e

    # 1. Generate unique filename with timestamp
    TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
    FILENAME="Screenshot_''${TIMESTAMP}.png"
    TEMP_FILE="/tmp/''${FILENAME}"

    # 2. Capture screenshot
    # -r: Region selection
    # -b: Background mode (no GUI)
    # -n: Non-notifying (silent)
    # -o: Output to file
    if spectacle -r -b -n -o "$TEMP_FILE"; then

      # 3. Check if file was actually created (user didn't press Esc)
      if [ -f "$TEMP_FILE" ]; then
        # Clear previous clipboard content
        wl-copy --clear

        # Copy the file path as a URI (Standard for file managers/browsers)
        printf "file://%s\n" "$TEMP_FILE" | wl-copy -t text/uri-list
      fi
    fi
  '';

in
{
  environment.systemPackages = [ magshot ];
}