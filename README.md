# Nested Steam Gamemode
> **Credit:** All credit goes to [hikariknight](https://github.com/HikariKnight) for the excellent [`bazzite-dx` PR](https://github.com/ublue-os/bazzite-dx/pull/125/files#diff-95375a553164600a7d4fed6d71470c5acd8aaee35a96ac0f99bf0ff7461be5a3R1-R67) that introduced this feature.

Launch Steam's Game Mode UI inside a nested Gamescope window on any Linux distribution. Handy for testing without logging out of your desktop session.

## Requirements

- Steam client (`steam` command)
- [Gamescope](https://github.com/ValveSoftware/gamescope)
- [YAD](https://github.com/v1cont/yad) for the configuration dialog

## Install

```bash
git clone https://github.com/xXJSONDeruloXx/nested-gamemode.git
cd nested-gamemode
sudo ./setup.sh                # installs to ~/.local/bin and ~/.local/share/applications
sudo ./setup.sh --system  # optional system-wide install
```

Add `--no-refresh` if your desktop database update hangs.

## Uninstall

```bash
./uninstall.sh                # removes user install
sudo ./uninstall.sh --system  # removes system-wide install
```

`--no-refresh` is also available during uninstall.

## Usage

- Launch `Nested Steam Gamemode` from your desktop menu, or run `gamemode-nested`.
- Configure frame limiter, window size, and HDR support via the dialog.
- Steam is stopped if it is already running, then restarted inside Gamescope.

To customize the Steam executable or arguments, set `STEAM_EXECUTABLE` or `STEAM_ARGS` before running the launcher.

## Debugging

Set `NESTED_DEBUG=1` and optionally `NESTED_DEBUG_LOG=/path/to/log` before running to capture verbose output:

```bash
NESTED_DEBUG=1 gamemode-nested
```

The launcher echoes the full Gamescope command so you can replay it manually for troubleshooting.
