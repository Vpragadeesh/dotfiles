-- for convenience
local fn = vim.fn

-- plugin dependencies
local dependencies = {
    {
        "stevearc/dressing.nvim",
        opts = {},
    },
    {
        "nvim-lua/plenary.nvim",
    },
    {
        "MunifTanjim/nui.nvim",
    },
    {
        "nvim-tree/nvim-web-devicons",
    },
    {
        "zbirenbaum/copilot.lua",
    },
    {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
            default = {
                embed_image_as_base64 = false,
                prompt_for_file_name = false,
                drag_and_drop = {
                    insert_mode = true,
                },
                use_absolute_path = true,
            },
        },
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
    },
}

-- plugin init function
local init = function () end

-- plugin opts
local opts = {
    provider = "copilot",
    auto_suggestions_provider = "copilot",
    providers = {
        copilot = {
            endpoint = "https://api.githubcopilot.com",
            model = "gpt-4o-2024-05-13",
            timeout = 30000,
        },
    },
    behaviour = {
        auto_suggestions = false,
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
    },
    mappings = {
        diff = {
            ours = "co",
            theirs = "ct",
            all_theirs = "ca",
            both = "cb",
            cursor = "cc",
            next = "]x",
            prev = "[x",
        },
        suggestion = {
            accept = "<M-l>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
        },
        jump = {
            next = "]]",
            prev = "[[",
        },
        submit = {
            normal = "<CR>",
            insert = "<C-s>",
        },
        sidebar = {
            switch_windows = "<Tab>",
            reverse_switch_windows = "<S-Tab>",
        },
    },
    hints = { enabled = true },
    windows = {
        position = "right",
        wrap = true,
        width = 30,
        sidebar_header = {
            align = "center",
            rounded = true,
        },
    },
    highlights = {
        diff = {
            current = "DiffText",
            incoming = "DiffAdd",
        },
    },
    diff = {
        autojump = true,
        list_opener = "copen",
    },
}

-- plugin config function
local config = function (_, opts)
    require("avante_lib").load()
    require("avante").setup(opts)
end

-- plugin keys
local keys = {
    {
        "<leader>aa",
        mode = { "n", "v" },
        function ()
            require("avante.api").ask()
        end,
        noremap = true,
        silent = true,
        desc = "avante: ask AI",
    },
    {
        "<leader>ar",
        mode = { "v" },
        function ()
            require("avante.api").refresh()
        end,
        noremap = true,
        silent = true,
        desc = "avante: refresh",
    },
    {
        "<leader>ae",
        mode = { "n", "v" },
        function ()
            require("avante.api").edit()
        end,
        noremap = true,
        silent = true,
        desc = "avante: edit selection",
    },
    {
        "<leader>ao",
        mode = { "n" },
        function ()
            require("avante").toggle()
        end,
        noremap = true,
        silent = true,
        desc = "avante: toggle sidebar",
    },
}

-- plugin configurations
return {
    "yetone/avante.nvim",
    version = false,
    enabled = true,
    lazy = false,
    event = "VeryLazy",
    cmd = {
        "AvanteAsk",
        "AvanteChat",
        "AvanteEdit",
        "AvanteRefresh",
        "AvanteSwitchProvider",
        "AvanteToggle",
    },
    ft = {},
    build = fn.has("win32") == 1 and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" or "make",
    dependencies = dependencies,
    init = init,
    opts = opts,
    config = config,
    keys = keys,
}
