#!/usr/bin/env fish
# Emit OSC 7 on every prompt so terminal (kitty) can determine the shell CWD.
# This enables kitty's `--cwd=current` behavior and makes new tabs inherit the
# directory the shell is currently in.

function __emit_osc7 --on-event fish_prompt
    # Determine a hostname safely (fall back to uname or /proc if hostname isn't available)
    if type -q hostname
        set -l host (hostname)
    else if type -q uname
        set -l host (uname -n)
    else if test -f /proc/sys/kernel/hostname
        set -l host (string trim (cat /proc/sys/kernel/hostname))
    else
        set -l host localhost
    end

    # Get cwd and URL-encode it if python3/python is available; otherwise at least
    # replace spaces so basic paths work.
    set -l cwd (pwd)
    if type -q python3
        set -l enccwd (python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "$cwd")
    else if type -q python
        set -l enccwd (python -c "import urllib,sys;print(__import__('urllib').parse.quote(sys.argv[1]))" "$cwd")
    else
        set -l enccwd (string replace ' ' '%20' -- $cwd)
    end

    printf '\e]7;file://%s%s\a' $host $enccwd
end
