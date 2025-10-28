#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [--user|--system] [--no-refresh]

Install Nested Gamemode launcher either for the current user (default) or system-wide.
Desktop database refresh can be skipped with --no-refresh if it hangs on your system.
EOF
}

# Check for required dependencies
check_dependencies() {
    local missing=()
    local optional_missing=()
    
    if ! command -v gamescope >/dev/null 2>&1; then
        missing+=("gamescope")
    fi
    
    if ! command -v yad >/dev/null 2>&1; then
        missing+=("yad")
    fi
    
    if ! command -v steam >/dev/null 2>&1; then
        missing+=("steam")
    fi
    
    if ! command -v mangoapp >/dev/null 2>&1; then
        optional_missing+=("mangohud (provides mangoapp)")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Error: Missing required dependencies:" >&2
        for dep in "${missing[@]}"; do
            echo "  - $dep" >&2
        done
        echo >&2
        echo "Installation instructions by distribution:" >&2
        echo >&2
        echo "Arch Linux / Manjaro:" >&2
        echo "  sudo pacman -S gamescope mangohud yad steam" >&2
        echo >&2
        echo "Fedora:" >&2
        echo "  sudo dnf install gamescope mangohud yad steam" >&2
        echo >&2
        echo "Ubuntu / Debian:" >&2
        echo "  sudo apt install gamescope mangohud yad steam" >&2
        echo "  (Note: You may need to add repositories for gamescope)" >&2
        echo >&2
        echo "For other distributions, install the missing packages using your package manager." >&2
        return 1
    fi
    
    if [[ ${#optional_missing[@]} -gt 0 ]]; then
        echo "Warning: Optional dependencies not found:" >&2
        for dep in "${optional_missing[@]}"; do
            echo "  - $dep (recommended for performance overlay)" >&2
        done
        echo >&2
    fi
    
    return 0
}

echo "Checking dependencies..."
if ! check_dependencies; then
    exit 1
fi
echo "All dependencies found."
echo

scope="user"
refresh_desktop=true
while [[ $# -gt 0 ]]; do
    case "$1" in
        --user) scope="user" ;;
        --system) scope="system" ;;
        --no-refresh) refresh_desktop=false ;;
        -h|--help) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
    shift
done

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ "$scope" == "system" ]]; then
    BIN_DIR=/usr/local/bin
    DESKTOP_DIR=/usr/share/applications
    if [[ $EUID -ne 0 ]]; then
        echo "System installation requires root privileges. Re-run with sudo." >&2
        exit 1
    fi
else
    BIN_DIR=${XDG_BIN_HOME:-"$HOME/.local/bin"}
    DESKTOP_DIR=${XDG_DATA_HOME:-"$HOME/.local/share"}/applications
fi

install -Dm755 "$SCRIPT_DIR/gamemode-nested" "$BIN_DIR/gamemode-nested"
install -Dm644 "$SCRIPT_DIR/gamemode-nested.desktop" "$DESKTOP_DIR/gamemode-nested.desktop"

if [[ "$refresh_desktop" == true ]]; then
    if command -v update-desktop-database >/dev/null 2>&1; then
        timeout 15 update-desktop-database "${DESKTOP_DIR%/*}" >/dev/null 2>&1 || true
    fi

    if command -v xdg-desktop-menu >/dev/null 2>&1; then
        timeout 15 xdg-desktop-menu forceupdate >/dev/null 2>&1 || true
    fi
else
    echo "Skipping desktop database refresh (--no-refresh)."
fi

echo "Nested Gamemode installed to:"
echo "  - $BIN_DIR/gamemode-nested"
echo "  - $DESKTOP_DIR/gamemode-nested.desktop"
echo
echo "Launch via desktop menu or run: gamemode-nested"
