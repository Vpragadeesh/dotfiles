local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- 🚀 Start a fresh tmux session for every new WezTerm window
-- This prevents workspace 1 and workspace 2 from sharing the same tmux session
config.default_prog = { "tmux", "new-session" }

-- 🚫 Remove the top tab bar completely
config.enable_tab_bar = false

-- 🎛️ Optional: tmux keybindings inside WezTerm
config.keys = {
  -- New tmux window (Ctrl+Shift+T)
  {
    key = "t",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString "\x02c",
  },

  -- Horizontal split (Ctrl+Shift+H)
  {
    key = "h",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString "\x02\"",
  },

  -- Vertical split (Ctrl+Shift+V)
  {
    key = "v",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SendString "\x02%",
  },
}

return config
