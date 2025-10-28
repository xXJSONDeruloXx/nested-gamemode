#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [--user|--system]

Remove Nested Gamemode launcher either from the current user (default) or system-wide install.
EOF
}

scope="user"
if [[ $# -gt 0 ]]; then
    case "$1" in
        --user) scope="user" ;;
        --system) scope="system" ;;
        -h|--help) usage; exit 0 ;;
        *) usage; exit 1 ;;
    esac
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if [[ "$scope" == "system" ]]; then
    BIN_DIR=/usr/local/bin
    DESKTOP_DIR=/usr/share/applications
    if [[ $EUID -ne 0 ]]; then
        echo "System removal requires root privileges. Re-run with sudo." >&2
        exit 1
    fi
else
    BIN_DIR=${XDG_BIN_HOME:-"$HOME/.local/bin"}
    DESKTOP_DIR=${XDG_DATA_HOME:-"$HOME/.local/share"}/applications
fi

removed_any=false

if [[ -e "$BIN_DIR/gamemode-nested" ]]; then
    rm -f "$BIN_DIR/gamemode-nested"
    echo "Removed $BIN_DIR/gamemode-nested"
    removed_any=true
fi

if [[ -e "$DESKTOP_DIR/gamemode-nested.desktop" ]]; then
    rm -f "$DESKTOP_DIR/gamemode-nested.desktop"
    echo "Removed $DESKTOP_DIR/gamemode-nested.desktop"
    removed_any=true
fi

if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "${DESKTOP_DIR%/*}" >/dev/null 2>&1 || true
fi

if command -v xdg-desktop-menu >/dev/null 2>&1; then
    xdg-desktop-menu forceupdate >/dev/null 2>&1 || true
fi

if [[ "$removed_any" == false ]]; then
    echo "No Nested Gamemode files found to remove in the selected scope."
fi
