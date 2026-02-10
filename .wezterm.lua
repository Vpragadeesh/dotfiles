local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Automatically launch tmux on startup
config.default_prog = { 'tmux', 'new-session', '-A', '-s', 'main' }

-- Alternative: If you want tmux to attach to an existing session or create a new one
-- config.default_prog = { '/bin/bash', '-c', 'tmux attach || tmux new' }
config.enable_tab_bar = false
-- Optional: Set up keybindings for tmux-related actions
config.keys = {
  -- Create a new tmux window with Ctrl+Shift+T
  {
    key = 't',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SendString '\x02c', -- Ctrl+b then c (tmux new window)
  },
  -- Split tmux pane horizontally with Ctrl+Shift+H
  {
    key = 'h',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SendString '\x02"', -- Ctrl+b then " (tmux horizontal split)
  },
  -- Split tmux pane vertically with Ctrl+Shift+V
  {
    key = 'v',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SendString '\x02%', -- Ctrl+b then % (tmux vertical split)
  },
}

return config
