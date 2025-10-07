-- for convenience
local api = vim.api
local keymap = vim.keymap

-- plugin dependencies
local dependencies = {
    {
        "zbirenbaum/copilot.lua",
    },
    {
        "nvim-lua/plenary.nvim",
    },
}

-- plugin init function
local init = function () end

-- plugin opts
local opts = {
    debug = false,
    show_help = true,
    agent = "copilot",
    model = "gpt-4o",
    temperature = 0.1,
    prompts = {
        Explain = {
            prompt = "/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.",
        },
        Review = {
            prompt = "/COPILOT_REVIEW Review the selected code.",
            callback = function (response, source)
                -- Do something with the response
            end,
        },
        Fix = {
            prompt = "/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.",
        },
        Optimize = {
            prompt = "/COPILOT_GENERATE Optimize the selected code to improve performance and readability.",
        },
        Docs = {
            prompt = "/COPILOT_GENERATE Please add documentation comment for the selection.",
        },
        Tests = {
            prompt = "/COPILOT_GENERATE Please generate tests for my code.",
        },
        FixDiagnostic = {
            prompt = "Please assist with the following diagnostic issue in file:",
            selection = function (source)
                local diagnostics = vim.diagnostic.get(0)
                if #diagnostics > 0 then
                    return diagnostics[1].message
                end
                return nil
            end,
        },
        Commit = {
            prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
            selection = function (source)
                return require("CopilotChat.select").gitdiff(source)
            end,
        },
        CommitStaged = {
            prompt = "Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.",
            selection = function (source)
                return require("CopilotChat.select").gitdiff(source, true)
            end,
        },
    },
    auto_follow_cursor = true,
    show_folds = true,
    highlight_selection = true,
    context = "buffers",
    agent_selection = "buffer",
    auto_insert_mode = true,
    clear_chat_on_new_prompt = false,
    history_path = vim.fn.stdpath("data") .. "/copilotchat_history",
    question_header = "## User ",
    answer_header = "## Copilot ",
    error_header = "## Error ",
    separator = "───",
    window = {
        layout = "vertical",
        width = 0.4,
        height = 0.6,
        row = nil,
        col = nil,
        border = "rounded",
        title = "Copilot Chat",
        footer = nil,
        zindex = 1,
    },
    mappings = {
        complete = {
            detail = "Use @<Tab> or /<Tab> for options.",
            insert = "<Tab>",
        },
        close = {
            normal = "q",
            insert = "<C-c>",
        },
        reset = {
            normal = "<C-l>",
            insert = "<C-l>",
        },
        submit_prompt = {
            normal = "<CR>",
            insert = "<C-s>",
        },
        accept_diff = {
            normal = "<C-y>",
            insert = "<C-y>",
        },
        yank_diff = {
            normal = "gy",
        },
        show_diff = {
            normal = "gd",
        },
        show_info = {
            normal = "gp",
        },
        show_context = {
            normal = "gs",
        },
    },
}

-- plugin config function
local config = function (_, opts)
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")

    chat.setup(opts)

    -- Auto commands for CopilotChat
    api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function ()
            vim.opt_local.relativenumber = true
            vim.opt_local.number = true
        end,
    })
end

-- plugin keys
local keys = {
    -- Show help actions with telescope
    {
        "<leader>ah",
        mode = { "n", "x" },
        function ()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.help_actions())
        end,
        noremap = true,
        silent = true,
        desc = "copilot chat - help actions",
    },
    -- Show prompts actions with telescope
    {
        "<leader>ap",
        mode = { "n", "x" },
        function ()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        noremap = true,
        silent = true,
        desc = "copilot chat - prompt actions",
    },
    {
        "<leader>ap",
        mode = { "x" },
        function ()
            local actions = require("CopilotChat.actions")
            require("CopilotChat.integrations.telescope").pick(actions.prompt_actions({
                selection = require("CopilotChat.select").visual,
            }))
        end,
        noremap = true,
        silent = true,
        desc = "copilot chat - prompt actions (visual)",
    },
    -- Code related commands
    {
        "<leader>ae",
        mode = { "x" },
        "<cmd>CopilotChatExplain<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - explain code",
    },
    {
        "<leader>at",
        mode = { "x" },
        "<cmd>CopilotChatTests<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - generate tests",
    },
    {
        "<leader>ar",
        mode = { "x" },
        "<cmd>CopilotChatReview<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - review code",
    },
    {
        "<leader>aR",
        mode = { "x" },
        "<cmd>CopilotChatRefactor<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - refactor code",
    },
    {
        "<leader>an",
        mode = { "x" },
        "<cmd>CopilotChatFixDiagnostic<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - fix diagnostic",
    },
    {
        "<leader>al",
        mode = { "n", "x" },
        "<cmd>CopilotChatReset<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - clear buffer and chat history",
    },
    -- Chat commands
    {
        "<leader>aa",
        mode = { "n" },
        function ()
            local input = vim.fn.input("Ask Copilot: ")
            if input ~= "" then
                require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
            end
        end,
        noremap = true,
        silent = true,
        desc = "copilot chat - quick chat",
    },
    {
        "<leader>ao",
        mode = { "n", "x" },
        "<cmd>CopilotChatOpen<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - open chat window",
    },
    {
        "<leader>ac",
        mode = { "n", "x" },
        "<cmd>CopilotChatClose<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - close chat window",
    },
    {
        "<leader>at",
        mode = { "n", "x" },
        "<cmd>CopilotChatToggle<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - toggle chat window",
    },
    {
        "<leader>ax",
        mode = { "n", "x" },
        "<cmd>CopilotChatStop<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - stop output",
    },
    -- Git commands
    {
        "<leader>am",
        mode = { "n", "x" },
        "<cmd>CopilotChatCommit<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - generate commit message for all changes",
    },
    {
        "<leader>aM",
        mode = { "n", "x" },
        "<cmd>CopilotChatCommitStaged<CR>",
        noremap = true,
        silent = true,
        desc = "copilot chat - generate commit message for staged changes",
    },
}

-- plugin configurations
return {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    enabled = true,
    lazy = true,
    event = {},
    cmd = {
        "CopilotChat",
        "CopilotChatOpen",
        "CopilotChatClose",
        "CopilotChatToggle",
        "CopilotChatStop",
        "CopilotChatReset",
        "CopilotChatSave",
        "CopilotChatLoad",
        "CopilotChatDebugInfo",
        "CopilotChatExplain",
        "CopilotChatReview",
        "CopilotChatFix",
        "CopilotChatOptimize",
        "CopilotChatDocs",
        "CopilotChatTests",
        "CopilotChatFixDiagnostic",
        "CopilotChatCommit",
        "CopilotChatCommitStaged",
    },
    ft = {},
    build = function ()
        vim.notify("Please update the remote plugins by running ':UpdateRemotePlugins', then restart Neovim.")
    end,
    dependencies = dependencies,
    init = init,
    opts = opts,
    config = config,
    keys = keys,
}
