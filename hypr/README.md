
## Hyprland configuration (personal dotfiles)

This directory contains a compact Hyprland configuration and supporting assets (lock images, wallpaper, helper scripts) meant to be used as your Hyprland compositor config under `~/.config/hypr`.

Short plan
- Provide a safe install path (copy), a convenient workflow (symlinks), and quick customization & troubleshooting notes.

Checklist
- Create or update `~/.config/hypr` with these files — instructions below
- Make helper scripts executable
- Backup any existing Hypr config before installing

Repository layout
- `hyprland.conf` — main Hyprland compositor configuration
- `hypridle.conf` — idle/locker helper config
- `hyprlock.conf` — lock screen config
- `hyprpaper.conf` — wallpaper helper config
- `bt_pause.sh` — small helper script (Bluetooth/audio pause behavior)
- `screenshot-bash.sh` — screenshot helper script
- `lock.png`, `lock_blur.png`, `lock_dim.png` — lock screen assets
- `wallpaper.jpg` — default wallpaper image
- `hypr/` — a mirrored subfolder with the same files (convenience)

Assumptions
- You're running Hyprland on Linux and use `~/.config/hypr` for your configuration.
- Adjust paths or commands if your distro or setup differs.

Quick safety backup

Before installing, back up your existing config:

```bash
mv ~/.config/hypr ~/.config/hypr.backup.$(date +%s) 2>/dev/null || true
mkdir -p ~/.config/hypr
```

Install — copy (safe, recommended for first use)

Copying preserves the repo as-is and avoids surprises from broken symlinks:

```bash
# from inside this repo directory
cp -r . ~/.config/hypr/
```

Then make helper scripts executable:

```bash
chmod +x ~/.config/hypr/*.sh
```

Apply the config

```bash
hyprctl reload
```

If `hyprctl` isn't available, log out and back in to restart the compositor.

Install — symlink (recommended for dotfile management)

If you prefer your repo to remain the source-of-truth, create relative symlinks:

```bash
mkdir -p ~/.config/hypr
# from inside the repo root
ln -rsf $(pwd)/* ~/.config/hypr/
```

This makes updates in the repo immediately active in `~/.config/hypr`.

Customization points
- Wallpaper and lock images: replace `wallpaper.jpg`, `lock.png`, `lock_blur.png`, `lock_dim.png` or edit `hyprpaper.conf` / `hyprlock.conf` to point to your files.
- `hyprland.conf`: change keybindings, workspace rules, monitor/output options, and compositor settings to match your hardware.
- Scripts: open `bt_pause.sh` and `screenshot-bash.sh` and adapt tools (playerctl, grim, slurp, swaylock, etc.) to what's installed on your system.
- Timeouts/blur/dim: tune `hypridle.conf` and `hyprlock.conf` values for your taste.

Common troubleshooting
- Nothing changed after `hyprctl reload`: confirm `hyprctl` exists and is in PATH, or restart your session.
- Missing images or lock problems: check file names and permissions in `~/.config/hypr`.
- Scripts failing: ensure executables exist (check shebangs) and run with `bash -x` for debugging:

```bash
bash -x ~/.config/hypr/screenshot-bash.sh
```

- Bar/panel widgets not showing: verify the panel program (waybar, hyprland-bar) is installed and configured.

Permissions and security
- Make scripts executable: `chmod +x ~/.config/hypr/*.sh`.
- Review scripts before running; they may call system utilities which differ across distros.

Tips & recommendations
- Use a dotfile manager (stow/chezmoi) for reproducible installs.
- Keep this repo as the source of truth and symlink into `~/.config/hypr`.
- Add comments to `hyprland.conf` for non-obvious keybinds or rules.

Next steps I can do for you
- Add a small `install.sh` that safely backs up and symlinks this repo into `~/.config/hypr`.
- Add a `LICENSE` (MIT) file.
- Annotate `hyprland.conf` with short explanations for keybindings.

Credits & links
- Hyprland: https://hyprland.org/ — read the official docs for advanced topics.

License
- This README doesn't include a license for the configuration itself. If you want, I can add an MIT `LICENSE` file to the repo.

Completion
- The file above documents installation, customization, and troubleshooting for this Hyprland config. If you'd like an automated installer or a `LICENSE`, tell me which and I'll add it.

## Keybindings

Note: `$mainMod` is set to `SUPER` (the Windows / ⊞ key) in the config. Below are all active bindings found in the repository with short explanations so you can understand and customize them easily.

Applications
- SUPER + RETURN — Launch a terminal (kitty).
- SUPER + T — Launch a terminal (kitty).
- SUPER + U — Launch a terminal running `nmtui` (kitty -e nmtui) for NetworkManager TUI.
- SUPER + E — Open Thunar file manager.
- SUPER + SHIFT + E — Open Thunar as root (`thunar /`).
- SUPER + C — Open VS Code (`code`).
- SUPER + B — Open Firefox web browser.
- SUPER + A — Open Elisa (music player).

Config editors / quick edits
- SUPER + SHIFT + Z — Open the Hyprland config in nvim inside kitty (`~/.config/hypr/hyprland.conf`).
- SUPER + SHIFT + X — Open Waybar `style.css` or `config` (two entries exist in the configs; both use the same key). You may want to pick one or duplicate intentionally.
- SUPER + SHIFT + V — Open Waybar `modules.json` in nvim (kitty).
- ALT + 0 — Set sink volume to 0% (pactl) — present in one config file.
- CTRL + 5 — Set sink volume to 50% (pactl) — present in one config file.
- ALT + Tab — Switch to the previous workspace.

Window management
- SUPER + Q — Close the focused window (`killactive`).
- SUPER + F — Toggle fullscreen for the active window (sets fullscreen to 1).
- SUPER + SHIFT + F — Toggle fullscreen (alternate binding present).
- SUPER + R — Toggle floating mode for the focused window (`togglefloating`).
- SUPER + G — Toggle split mode for tiled windows (`togglesplit`).
- SUPER + Arrow keys (Left/Right/Up/Down) — Move the focused window in the dwindle layout (movewindow l/r/u/d).
- SUPER + H / L / K / J — Vim-style keys to move focused window left/right/up/down.

Mouse window actions
- SUPER + mouse:272 — Move window by dragging (bindm movewindow).
- SUPER + mouse:273 — Resize window by dragging (bindm resizewindow).
- SUPER + (bindm) Z — Move window (alternate bindm entry).
- SUPER + (bindm) X — Resize window (alternate bindm entry).
- SUPER + mouse:W — Toggle floating for the window under the pointer.

Workspaces
- SUPER + 1..9 — Switch to workspace 1..9.
- SUPER + CTRL + Left / Right — Switch to previous/next numeric workspace (r-1 / r+1).
- SUPER + CTRL + Down — Go to an empty workspace.
- SUPER + SHIFT + 1..9 — Move focused window to workspace 1..9.
- SUPER + mouse_down — Switch to next workspace (r+1).
- SUPER + mouse_up — Switch to previous workspace (r-1).
- SUPER + SHIFT + mouse_down / mouse_up — Move focused window to next/previous workspace.

Resize (keyboard)
- SUPER + SHIFT + Right — Increase width of active tiled area (resizeactive 90 0).
- SUPER + SHIFT + Left — Decrease width of active tiled area (resizeactive -90 0).
- SUPER + SHIFT + Up — Decrease height of active tiled area (resizeactive 0 -90).
- SUPER + SHIFT + Down — Increase height of active tiled area (resizeactive 0 90).

Actions & utilities
- SUPER + D — Open application launcher (rofi drun).
- SUPER + SHIFT + B — Restart Waybar (`pkill waybar && waybar`). Useful for reloading bar style/modules.
- SUPER + SHIFT + N — Reload Hyprland config (`hyprctl reload`).
- SUPER + SHIFT + Q — Open logout menu (`wlogout`).
- SUPER + P — Lock the screen (`hyprlock`).
- SUPER + I — Decrease brightness by 10% (`brightnessctl -q s 10%-`).
- SUPER + O — Increase brightness by 10% (`brightnessctl -q s +10%`).
- SUPER + ALT + S — Move to special workspace silently (`movetoworkspacesilent special`).
- SUPER + S — Toggle special workspace (`togglespecialworkspace special`).
- SUPER + Tab — Toggle special workspace (alternate binding).

Screenshots (variants in configs)
- SUPER + SHIFT + S — Root config: run `screenshot-bash.sh` at `/home/pragadeesh/.config/hypr/screenshot-bash.sh` (project helper script).
- SUPER + Print — In one copy of the config: `grim -g "$(slurp)" /tmp/screenshot.png` and notify (interactive region screenshot).
- SUPER + SHIFT + S — In the other copy: save a time-stamped screenshot to `~/Pictures` and copy to clipboard (grim + slurp + wl-copy + notify-send).
- Print (no modifier) — Capture full-screen screenshot and pipe to `wl-copy` (copies image to clipboard).

Function / media keys
- XF86MonBrightnessUp — Increase brightness (`brightnessctl -q s +5%`).
- XF86MonBrightnessDown — Decrease brightness (`brightnessctl -q s 5%-` or `-5%` in other file).
- XF86AudioMicMute — Toggle microphone mute (`pactl set-source-mute @DEFAULT_SOURCE@ toggle`).
- XF86AudioPlay / F12 — Play/pause media (`playerctl play-pause`).
- XF86AudioNext / F3 — Next track (`playerctl next`).
- XF86AudioPrev / F2 — Previous track (`playerctl previous`).
- XF86AudioRaiseVolume — Increase volume (either `pamixer -i 5` or `pactl set-sink-volume @DEFAULT_SINK@ +5%` depending on config copy).
- XF86AudioLowerVolume — Decrease volume (either `pamixer -d 5` or `pactl set-sink-volume @DEFAULT_SINK@ -5%`).
- XF86AudioMute — Toggle mute (`pamixer -t` or `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` depending on config copy).
- XF86Lock — Lock the screen (`hyprlock`).

Notes about duplicates & variants
- The repo contains two `hyprland.conf` copies with mostly identical bindings. A few bindings differ in the command used (media volume and screenshot handling). Both sets are documented above; pick which command/tool (pamixer/pactl/wpctl) you prefer and update the config accordingly.
- There are two entries bound to `SUPER + SHIFT + X` in one config file opening different Waybar files. If that is not intentional, change one to a different key.

How to include these in your README
- This section is now part of `README.md`. If you'd like a separate `KEYBINDINGS.md` or a shorter cheat-sheet (for printing), I can create that too.


