# Noctalia Configuration Guide

## Overview
This is a comprehensive Noctalia configuration with all waybar features ported to Noctalia's plugin system.

**Noctalia** is a beautiful, minimal desktop shell for Wayland that supports:
- 6+ Wayland compositors (Niri, Hyprland, Sway, Scroll, MangoWC, Labwc)
- 126+ community plugins
- Highly customizable appearance and behavior
- Minimal, distraction-free design

## File Structure

```
noctalia/
├── config.toml              # Main configuration file
├── theme.toml               # Theme and color scheme
├── plugins/                 # Plugin configurations
│   ├── workspaces-plugin.toml     # Workspace management
│   ├── window-info.toml           # Active window display
│   ├── pulseaudio.toml            # Audio control
│   ├── disk-monitor.toml          # Disk usage
│   ├── network-monitor.toml       # Network status
│   ├── media-player.toml          # MPRIS media control
│   └── system-monitor.toml        # CPU, Memory, Battery, Temp
└── README.md                # This file
```

## Installation

1. Copy this folder to `~/.config/noctalia/` or the appropriate config directory for your system:
```bash
mkdir -p ~/.config/noctalia
cp -r noctalia/* ~/.config/noctalia/
```

2. Ensure all required plugins are installed:
```bash
noctalia --install-plugins
```

3. Restart Noctalia or reload the configuration:
```bash
noctalia --reload
```

## Features

### Panel Layout
- **Left Section**: Workspaces, Window Title, Audio, Backlight, Disk
- **Center Section**: Clock, Temperature
- **Right Section**: CPU, Memory, Battery, Network, Bluetooth, Media Player, System Tray

### Waybar Features Ported

| Waybar Module | Noctalia Plugin | Status |
|---------------|-----------------|--------|
| niri/workspaces | workspaces-plugin | ✓ |
| niri/window | window-info | ✓ |
| pulseaudio | pulseaudio | ✓ |
| backlight | system-monitor | ✓ |
| disk | disk-monitor | ✓ |
| clock | built-in | ✓ |
| temperature | system-monitor | ✓ |
| cpu | system-monitor | ✓ |
| memory | system-monitor | ✓ |
| battery | system-monitor | ✓ |
| network | network-monitor | ✓ |
| mpris | media-player | ✓ |
| bluetooth | system-monitor* | ✓ |
| tray | system-tray | ✓ |

*Bluetooth control included in system-monitor

### Key Interactions

**Workspaces**
- Click: Activate workspace
- Scroll Up: Next workspace
- Scroll Down: Previous workspace

**Audio**
- Click: Toggle mute
- Scroll: Volume adjustment
- Right-click: Open mixer

**Network**
- Click: Network info
- Right-click: Network manager

**Media Player**
- Click: Play/Pause
- Scroll Up: Next track
- Scroll Down: Previous track

**System Monitor (CPU, Memory, Battery)**
- Click: Open system monitor
- Scroll: Backlight adjustment

## Customization

### Colors
Edit `theme.toml` to customize colors. Main color groups:
- `primary`, `secondary`, `accent`: Main UI colors
- Status colors: `success`, `warning`, `critical`, `info`
- Component-specific: `cpu_color`, `memory_color`, etc.

### Layout
Edit `config.toml` panel widgets section to:
- Add/remove widgets
- Change widget position (left, center, right)
- Adjust spacing and margins

### Fonts
In `theme.toml`, modify typography section:
- `font_ui`: Main UI font
- `font_mono`: Monospace font
- `size_*`: Font sizes

### Plugin Behavior
Each plugin has its own config file in `plugins/`:
- Modify display formats
- Adjust update intervals
- Configure interactions (click, scroll, etc.)
- Customize colors per module

## Performance Tips

1. **Update Intervals**: Increase intervals in plugin configs if CPU usage is high
   - Default: 1000ms for most modules
   - Can increase to 2000-5000ms for less critical updates

2. **Blur Effects**: Toggle `blur_enabled` in `config.toml` if performance is poor

3. **Animation**: Disable `animations` in main config for lower-end systems

4. **Plugin Management**: Disable unused plugins in `config.toml` plugins section

## Troubleshooting

**Panel not showing**
- Ensure Noctalia is running: `noctalia --version`
- Check logs: `tail -f /tmp/noctalia.log`

**Plugins not loading**
- Verify plugin names in enabled list match file names
- Check plugin dependencies: `noctalia --plugin-info <plugin-name>`

**Colors not applying**
- Clear cache: `rm -rf ~/.cache/noctalia/*`
- Reload: `noctalia --reload`

**Performance issues**
- Reduce update intervals in plugin configs
- Disable blur effects
- Disable animations

## Additional Resources

- **Official Docs**: https://docs.noctalia.dev/v4
- **Plugin Repository**: https://noctalia.dev/plugins
- **Community Discord**: https://discord.noctalia.dev/
- **GitHub**: https://github.com/noctalia-dev/noctalia-shell

## Notes

- This config is designed for a modern Wayland setup
- Tested with Niri, but compatible with other supported compositors
- All waybar features have been adapted for Noctalia's plugin system
- Colors match the dark theme from the original waybar config

## License & Attribution

Adapted from waybar configuration for Noctalia by pragadeesh.
Original waybar config available in `/home/pragadeesh/dotfiles/waybar/`

---

**Created**: 2026
**Noctalia Version**: v4+
**Last Updated**: May 29, 2026
