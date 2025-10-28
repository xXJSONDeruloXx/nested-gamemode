#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<EOF
Usage: $0 [--user|--system] [--no-refresh]

Remove Nested Gamemode launcher either from the current user (default) or system-wide install.
Desktop database refresh can be skipped with --no-refresh if it hangs on your system.
EOF
}

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

if [[ "$removed_any" == false ]]; then
    echo "No Nested Gamemode files found to remove in the selected scope."
fi
