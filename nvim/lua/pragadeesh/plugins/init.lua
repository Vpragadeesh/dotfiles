return {
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
    },
    {
        "nvim-tree/nvim-web-devicons",
        lazy = true,
    },
    {
        "MunifTanjim/nui.nvim",
        lazy = true,
    },
    {
        "rafamadriz/friendly-snippets",
        lazy = true,
    },
    {
        "moyiz/blink-emoji.nvim",
        lazy = true,
        enabled = false,  -- Disabled for lightweight config
    },
    {
        "giuxtaposition/blink-cmp-copilot",
        lazy = true,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        lazy = true,
    },
    {
        "nickjvandyke/opencode.nvim",
        enabled = true, -- enabled with proper keybindings
        lazy = true,
        event = "VeryLazy",
        config = function()
            local keymap = vim.keymap

            -- Ask opencode a question
            keymap.set({ "n", "x" }, "<leader>oa", function()
                require("opencode").ask("@this: ", { submit = true })
            end, {
                noremap = true,
                silent = true,
                desc = "Ask opencode…",
            })

            -- Select from opencode actions
            keymap.set({ "n", "x" }, "<leader>os", function()
                require("opencode").select()
            end, {
                noremap = true,
                silent = true,
                desc = "Execute opencode action…",
            })

            -- Toggle opencode
            keymap.set({ "n", "t" }, "<leader>ot", function()
                require("opencode").toggle()
            end, {
                noremap = true,
                silent = true,
                desc = "Toggle opencode",
            })

            -- Operator mode (select text then press 'go' to add to opencode)
            keymap.set("n", "go", function()
                return require("opencode").operator("@this ")
            end, {
                noremap = true,
                expr = true,
                desc = "Add range to opencode",
            })

            -- Add current line to opencode
            keymap.set("n", "goo", function()
                return require("opencode").operator("@this ") .. "_"
            end, {
                noremap = true,
                expr = true,
                desc = "Add line to opencode",
            })
        end,
    },
}
