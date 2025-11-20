return {
    "tamton-aquib/mpv.nvim",
    cmd = "MpvToggle",
    keys = {
        { "<leader>mp", "<cmd>MpvToggle<cr>", desc = "Toggle MPV Player" },
    },
    opts = {
        width = 50,
        height = 5,
        border = "rounded",
        setup_widgets = false,
        timer = {
            after = 1000,
            throttle = 250,
        },
    },
}
