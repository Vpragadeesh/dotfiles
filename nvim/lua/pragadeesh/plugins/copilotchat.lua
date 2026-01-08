-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║                    VS CODE COPILOT AGENT CLONE                           ║
-- ║                  Complete Copilot Experience in Neovim                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap

-- ============================================================================
-- DEPENDENCIES
-- ============================================================================
local dependencies = {
    { "zbirenbaum/copilot.lua" },
    { "nvim-lua/plenary.nvim" },
}

-- ============================================================================
-- VS CODE-STYLE PROMPTS (All Slash Commands)
-- ============================================================================
local prompts = {
    -- ══════════════════════════════════════════════════════════════════════
    -- CODE UNDERSTANDING
    -- ══════════════════════════════════════════════════════════════════════
    Explain = {
        prompt = "> /COPILOT_EXPLAIN\n\nWrite a detailed explanation of how the selected code works. Be thorough and explain step by step.",
    },
    ExplainSimple = {
        prompt = "> /COPILOT_EXPLAIN\n\nExplain this code in simple terms, as if explaining to a junior developer.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- CODE GENERATION & EDITING
    -- ══════════════════════════════════════════════════════════════════════
    Fix = {
        prompt = "> /COPILOT_GENERATE\n\nThere is a problem in this code. Identify the issue, explain what's wrong, and provide the corrected code.",
    },
    Optimize = {
        prompt = "> /COPILOT_GENERATE\n\nOptimize the selected code to improve performance and readability. Maintain the same functionality.",
    },
    Refactor = {
        prompt = "> /COPILOT_GENERATE\n\nRefactor this code to improve its structure, readability, and maintainability without changing its behavior.",
    },
    Simplify = {
        prompt = "> /COPILOT_GENERATE\n\nSimplify this code while maintaining its functionality. Remove unnecessary complexity.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- DOCUMENTATION
    -- ══════════════════════════════════════════════════════════════════════
    Docs = {
        prompt = "> /COPILOT_GENERATE\n\nAdd comprehensive documentation comments to this code. Use the appropriate format for the language (JSDoc, docstrings, etc.).",
    },
    DocsInline = {
        prompt = "> /COPILOT_GENERATE\n\nAdd inline comments explaining each significant line or block of this code.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- TESTING
    -- ══════════════════════════════════════════════════════════════════════
    Tests = {
        prompt = "> /COPILOT_GENERATE\n\nGenerate comprehensive unit tests for this code. Include edge cases and use the appropriate testing framework for the language.",
    },
    TestsE2E = {
        prompt = "> /COPILOT_GENERATE\n\nGenerate end-to-end tests for this code. Focus on user flows and integration points.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- CODE REVIEW
    -- ══════════════════════════════════════════════════════════════════════
    Review = {
        prompt = "> /COPILOT_REVIEW\n\nReview this code thoroughly. Check for:\n- Bugs and logic errors\n- Security vulnerabilities\n- Performance issues\n- Code style and best practices\n\nProvide specific suggestions for improvement.",
    },
    Security = {
        prompt = "> /COPILOT_REVIEW\n\nAnalyze this code for security vulnerabilities. Check for common issues like injection, XSS, CSRF, authentication flaws, etc.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- DIAGNOSTICS & FIXES
    -- ══════════════════════════════════════════════════════════════════════
    FixDiagnostic = {
        prompt = "> /COPILOT_GENERATE\n\nFix the following diagnostic issues in this code:",
        selection = function(source)
            local diagnostics = vim.diagnostic.get(0)
            if #diagnostics == 0 then
                return nil
            end
            local lines = { "Diagnostics:" }
            for i, d in ipairs(diagnostics) do
                if i > 10 then
                    table.insert(lines, "... and " .. (#diagnostics - 10) .. " more")
                    break
                end
                local severity = vim.diagnostic.severity[d.severity] or "INFO"
                table.insert(lines, string.format("- [%s] Line %d: %s", severity, d.lnum + 1, d.message))
            end
            return table.concat(lines, "\n")
        end,
    },
    FixError = {
        prompt = "> /COPILOT_GENERATE\n\nFix the error on the current line. Explain what was wrong and show the corrected code.",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- GIT INTEGRATION
    -- ══════════════════════════════════════════════════════════════════════
    Commit = {
        prompt = "> #git:staged\n\nWrite a commit message following the Conventional Commits format. Title should be max 50 characters, body wrapped at 72 characters. Be concise but descriptive.",
        selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
        end,
    },
    CommitAll = {
        prompt = "> #git:unstaged\n\nWrite a commit message for all changes following the Conventional Commits format.",
        selection = function(source)
            return require("CopilotChat.select").gitdiff(source, false)
        end,
    },
    PRDescription = {
        prompt = "> #git:staged\n\nWrite a comprehensive Pull Request description. Include:\n- Summary of changes\n- Motivation and context\n- Type of change\n- Testing done",
        selection = function(source)
            return require("CopilotChat.select").gitdiff(source, true)
        end,
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- AGENT MODE PROMPTS (@workspace context)
    -- ══════════════════════════════════════════════════════════════════════
    Workspace = {
        prompt = "> @workspace\n\nAnalyze the current workspace structure and provide an overview of the project architecture.",
        selection = function(source)
            -- Get project files
            local files = vim.fn.systemlist("find . -type f -name '*.lua' -o -name '*.py' -o -name '*.js' -o -name '*.ts' 2>/dev/null | head -50")
            return "Project files:\n" .. table.concat(files, "\n")
        end,
    },
    NewFeature = {
        prompt = "> @workspace /new\n\nI want to create a new feature. Help me plan and implement it step by step.",
    },
    Debug = {
        prompt = "> /COPILOT_GENERATE\n\nHelp me debug this code. Add debug statements and explain how to trace the issue.",
    },
}

-- ============================================================================
-- PLUGIN OPTIONS (VS Code-like Configuration)
-- ============================================================================
local opts = {
    debug = false,
    log_level = "warn",

    -- Model Configuration (VS Code Agent models)
    model = "gpt-4o",
    temperature = 0.1,

    -- Agent capabilities
    agent = "copilot",

    -- Context settings (like VS Code @workspace)
    context = "buffers", -- Can be: buffers, buffer, selection, none

    -- Prompts
    prompts = prompts,

    -- Chat behavior
    auto_follow_cursor = true,
    auto_insert_mode = true,
    insert_at_end = true,
    clear_chat_on_new_prompt = false,
    show_help = true,
    show_folds = true,
    highlight_selection = true,
    highlight_headers = true,
    history_path = fn.stdpath("data") .. "/copilotchat_history",

    -- VS Code-style headers
    question_header = "  User ",
    answer_header = "  Copilot ",
    error_header = "  Error ",
    separator = "───",

    -- Main Chat Window (VS Code-style sidebar)
    window = {
        layout = "vertical",
        width = 0.4,
        height = 0.5,
        border = "rounded",
        title = "  Copilot Chat ",
        footer = nil,
        zindex = 50,
    },

    -- Key mappings inside chat window (VS Code style)
    mappings = {
        complete = {
            detail = "Use @<Tab> for context, /<Tab> for commands",
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
            insert = "<C-CR>",
        },
        accept_diff = {
            normal = "<C-y>",
            insert = "<C-y>",
        },
        yank_diff = {
            normal = "gy",
            register = '"',
        },
        show_diff = {
            normal = "gd",
        },
        show_info = {
            normal = "gi",
        },
        show_context = {
            normal = "gc",
        },
        show_help = {
            normal = "g?",
        },
    },
}

-- ============================================================================
-- PLUGIN CONFIG (VS Code Agent Experience)
-- ============================================================================
local config = function(_, opts)
    local chat = require("CopilotChat")
    local select = require("CopilotChat.select")

    chat.setup(opts)

    -- ────────────────────────────────────────────────────────────────────────
    -- Auto Commands
    -- ────────────────────────────────────────────────────────────────────────
    api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
            vim.opt_local.relativenumber = true
            vim.opt_local.number = true
            vim.opt_local.signcolumn = "no"
            vim.opt_local.wrap = true
            vim.opt_local.linebreak = true
        end,
    })

    -- ────────────────────────────────────────────────────────────────────────
    -- USER COMMANDS (VS Code Copilot Agent Commands)
    -- ────────────────────────────────────────────────────────────────────────

    -- ══════════════════════════════════════════════════════════════════════
    -- QUICK CHAT (Like VS Code's Ctrl+Shift+I inline input)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotQuickChat", function()
        vim.ui.input({
            prompt = " Ask Copilot: ",
            default = "",
        }, function(input)
            if input and input ~= "" then
                chat.ask(input, {
                    selection = select.buffer,
                })
            end
        end)
    end, { desc = "Quick chat with Copilot" })

    -- ══════════════════════════════════════════════════════════════════════
    -- INLINE CHAT (Like VS Code's Ctrl+I on selection)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotInlineChat", function()
        vim.ui.input({
            prompt = " Edit with Copilot: ",
            default = "",
        }, function(input)
            if input and input ~= "" then
                chat.ask(input, {
                    selection = select.visual,
                })
            end
        end)
    end, { range = true, desc = "Inline chat with selection" })

    -- ══════════════════════════════════════════════════════════════════════
    -- AGENT MODE (Like VS Code's @workspace agent)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotAgent", function()
        vim.ui.input({
            prompt = " Agent @workspace: ",
            default = "",
        }, function(input)
            if input and input ~= "" then
                -- Include workspace context
                local cwd = fn.getcwd()
                local context_prompt = string.format(
                    "@workspace (cwd: %s)\n\n%s",
                    cwd,
                    input
                )
                chat.ask(context_prompt, {
                    selection = function(source)
                        -- Gather buffer context
                        local buffers = {}
                        for _, buf in ipairs(api.nvim_list_bufs()) do
                            if api.nvim_buf_is_loaded(buf) and api.nvim_buf_get_option(buf, 'buflisted') then
                                local name = api.nvim_buf_get_name(buf)
                                if name ~= "" then
                                    table.insert(buffers, name:gsub(cwd .. "/", ""))
                                end
                            end
                        end
                        return "Open buffers:\n" .. table.concat(buffers, "\n")
                    end,
                })
            end
        end)
    end, { desc = "Copilot Agent with workspace context" })

    -- ══════════════════════════════════════════════════════════════════════
    -- SLASH COMMANDS PICKER (Like VS Code's / menu)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotCommands", function()
        local commands = {
            { cmd = "Explain", icon = "", desc = "Explain how the code works" },
            { cmd = "Fix", icon = "", desc = "Fix problems in the code" },
            { cmd = "Optimize", icon = "", desc = "Optimize for performance" },
            { cmd = "Refactor", icon = "", desc = "Refactor the code" },
            { cmd = "Simplify", icon = "", desc = "Simplify the code" },
            { cmd = "Docs", icon = "", desc = "Add documentation" },
            { cmd = "Tests", icon = "", desc = "Generate unit tests" },
            { cmd = "Review", icon = "", desc = "Code review" },
            { cmd = "Security", icon = "", desc = "Security analysis" },
            { cmd = "FixDiagnostic", icon = "", desc = "Fix LSP diagnostics" },
            { cmd = "Commit", icon = "", desc = "Generate commit message" },
            { cmd = "Debug", icon = "", desc = "Help debug this code" },
        }

        vim.ui.select(commands, {
            prompt = " Copilot Commands (/):",
            format_item = function(item)
                return string.format("%s  /%s - %s", item.icon, item.cmd:lower(), item.desc)
            end,
        }, function(choice)
            if choice then
                chat.ask("/" .. choice.cmd, {
                    selection = select.visual or select.buffer,
                })
            end
        end)
    end, { desc = "Copilot slash commands picker" })

    -- ══════════════════════════════════════════════════════════════════════
    -- CONTEXT PICKER (Like VS Code's @ menu)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotContext", function()
        local contexts = {
            { ctx = "buffer", icon = "", desc = "Current buffer" },
            { ctx = "buffers", icon = "", desc = "All open buffers" },
            { ctx = "selection", icon = "󰒅", desc = "Selected text" },
            { ctx = "file", icon = "", desc = "Specific file" },
            { ctx = "workspace", icon = "", desc = "Entire workspace" },
        }

        vim.ui.select(contexts, {
            prompt = " Select Context (@):",
            format_item = function(item)
                return string.format("%s  @%s - %s", item.icon, item.ctx, item.desc)
            end,
        }, function(choice)
            if choice then
                vim.ui.input({
                    prompt = string.format(" @%s | Ask Copilot: ", choice.ctx),
                }, function(input)
                    if input and input ~= "" then
                        local sel
                        if choice.ctx == "buffer" then
                            sel = select.buffer
                        elseif choice.ctx == "buffers" then
                            sel = select.buffers
                        elseif choice.ctx == "selection" then
                            sel = select.visual
                        else
                            sel = select.buffer
                        end
                        chat.ask(input, { selection = sel })
                    end
                end)
            end
        end)
    end, { desc = "Copilot context picker" })

    -- ══════════════════════════════════════════════════════════════════════
    -- MODEL SELECTOR (Like VS Code's model dropdown)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotModels", function()
        chat.select_model()
    end, { desc = "Select Copilot model" })

    -- ══════════════════════════════════════════════════════════════════════
    -- AGENT SELECTOR (Like VS Code's Agent dropdown)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotAgents", function()
        chat.select_agent()
    end, { desc = "Select Copilot agent" })

    -- ══════════════════════════════════════════════════════════════════════
    -- QUICK ACTIONS (Bottom bar style actions)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotActions", function()
        local actions = {
            { action = "ask", icon = "󰭻", desc = "Ask anything" },
            { action = "explain", icon = "", desc = "Explain this code" },
            { action = "fix", icon = "", desc = "Fix this code" },
            { action = "optimize", icon = "", desc = "Optimize this code" },
            { action = "tests", icon = "", desc = "Write tests" },
            { action = "docs", icon = "", desc = "Add documentation" },
            { action = "review", icon = "", desc = "Review this code" },
            { action = "commit", icon = "", desc = "Generate commit message" },
            { action = "toggle", icon = "", desc = "Toggle chat panel" },
            { action = "reset", icon = "", desc = "Clear conversation" },
        }

        vim.ui.select(actions, {
            prompt = "  Copilot Actions:",
            format_item = function(item)
                return string.format("%s  %s", item.icon, item.desc)
            end,
        }, function(choice)
            if not choice then return end

            if choice.action == "ask" then
                vim.cmd("CopilotQuickChat")
            elseif choice.action == "toggle" then
                chat.toggle()
            elseif choice.action == "reset" then
                chat.reset()
            elseif choice.action == "commit" then
                chat.ask("/Commit")
            else
                chat.ask("/" .. choice.action:gsub("^%l", string.upper), {
                    selection = select.visual or select.buffer,
                })
            end
        end)
    end, { desc = "Copilot quick actions" })

    -- ══════════════════════════════════════════════════════════════════════
    -- NEW CHAT (Clear and start fresh)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotNewChat", function()
        chat.reset()
        chat.open()
    end, { desc = "Start new Copilot chat" })

    -- ══════════════════════════════════════════════════════════════════════
    -- EDIT IN PLACE (Like VS Code inline edit)
    -- ══════════════════════════════════════════════════════════════════════
    api.nvim_create_user_command("CopilotEdit", function()
        vim.ui.input({
            prompt = "  Edit instruction: ",
        }, function(input)
            if input and input ~= "" then
                chat.ask("/COPILOT_GENERATE\n\n" .. input, {
                    selection = select.visual,
                    window = {
                        layout = "float",
                        relative = "cursor",
                        width = 0.6,
                        height = 0.4,
                        row = 1,
                    },
                })
            end
        end)
    end, { range = true, desc = "Edit selection with Copilot" })
end

-- ============================================================================
-- KEYBINDINGS (VS Code Style)
-- ============================================================================
local keys = {
    -- ══════════════════════════════════════════════════════════════════════
    -- MAIN CHAT CONTROLS (Like VS Code)
    -- ══════════════════════════════════════════════════════════════════════

    -- Ctrl+Shift+I: Toggle chat panel (VS Code exact)
    {
        "<C-S-i>",
        "<cmd>CopilotChatToggle<CR>",
        mode = { "n", "x" },
        desc = " Toggle chat panel",
    },

    -- Leader+ai: Toggle chat (alternative)
    {
        "<leader>ai",
        "<cmd>CopilotChatToggle<CR>",
        mode = { "n", "x" },
        desc = " Toggle chat panel",
    },

    -- Leader+at: Toggle (explicit)
    {
        "<leader>at",
        "<cmd>CopilotChatToggle<CR>",
        mode = { "n", "x" },
        desc = " Toggle chat panel",
    },

    -- Ctrl+I in normal: Quick input (VS Code exact)
    {
        "<C-i>",
        "<cmd>CopilotQuickChat<CR>",
        mode = { "n" },
        desc = " Quick chat input",
    },

    -- Ctrl+I in visual: Inline edit (VS Code exact)
    {
        "<C-i>",
        "<cmd>CopilotInlineChat<CR>",
        mode = { "x" },
        desc = " Inline chat",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- QUICK ACTIONS (<leader>a prefix)
    -- ══════════════════════════════════════════════════════════════════════

    -- Ask (normal mode - buffer context)
    {
        "<leader>aa",
        "<cmd>CopilotQuickChat<CR>",
        mode = { "n" },
        desc = " Ask Copilot",
    },

    -- Ask (visual mode - selection context)
    {
        "<leader>aa",
        "<cmd>CopilotInlineChat<CR>",
        mode = { "x" },
        desc = " Ask about selection",
    },

    -- Agent mode with @workspace
    {
        "<leader>aw",
        "<cmd>CopilotAgent<CR>",
        mode = { "n" },
        desc = " Agent @workspace",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- SLASH COMMANDS (/command)
    -- ══════════════════════════════════════════════════════════════════════

    -- /explain
    {
        "<leader>ae",
        function()
            require("CopilotChat").ask("/Explain", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "n", "x" },
        desc = "/explain",
    },

    -- /fix
    {
        "<leader>af",
        function()
            require("CopilotChat").ask("/Fix", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "n", "x" },
        desc = "/fix",
    },

    -- /optimize
    {
        "<leader>ao",
        function()
            require("CopilotChat").ask("/Optimize", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/optimize",
    },

    -- /docs
    {
        "<leader>ad",
        function()
            require("CopilotChat").ask("/Docs", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/docs",
    },

    -- /tests
    {
        "<leader>aT",
        function()
            require("CopilotChat").ask("/Tests", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/tests",
    },

    -- /review
    {
        "<leader>ar",
        function()
            require("CopilotChat").ask("/Review", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/review",
    },

    -- /refactor
    {
        "<leader>aR",
        function()
            require("CopilotChat").ask("/Refactor", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/refactor",
    },

    -- /simplify
    {
        "<leader>as",
        function()
            require("CopilotChat").ask("/Simplify", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/simplify",
    },

    -- /security
    {
        "<leader>aS",
        function()
            require("CopilotChat").ask("/Security", {
                selection = require("CopilotChat.select").visual,
            })
        end,
        mode = { "x" },
        desc = "/security",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- DIAGNOSTICS & FIXES
    -- ══════════════════════════════════════════════════════════════════════

    -- Fix diagnostics
    {
        "<leader>an",
        "<cmd>CopilotChatFixDiagnostic<CR>",
        mode = { "n" },
        desc = " Fix diagnostics",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- GIT INTEGRATION
    -- ══════════════════════════════════════════════════════════════════════

    -- Commit message
    {
        "<leader>am",
        "<cmd>CopilotChatCommit<CR>",
        mode = { "n" },
        desc = " Generate commit message",
    },

    -- Commit staged
    {
        "<leader>aM",
        function()
            require("CopilotChat").ask("/Commit", {
                selection = function(source)
                    return require("CopilotChat.select").gitdiff(source, true)
                end,
            })
        end,
        mode = { "n" },
        desc = " Commit staged changes",
    },

    -- PR Description
    {
        "<leader>aP",
        "<cmd>CopilotChatPRDescription<CR>",
        mode = { "n" },
        desc = " Generate PR description",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- PICKERS & MENUS
    -- ══════════════════════════════════════════════════════════════════════

    -- Commands picker (/ menu)
    {
        "<leader>a/",
        "<cmd>CopilotCommands<CR>",
        mode = { "n", "x" },
        desc = " Slash commands",
    },

    -- Context picker (@ menu)
    {
        "<leader>a@",
        "<cmd>CopilotContext<CR>",
        mode = { "n" },
        desc = " Context picker",
    },

    -- Actions picker
    {
        "<leader>ap",
        "<cmd>CopilotActions<CR>",
        mode = { "n", "x" },
        desc = " Actions picker",
    },

    -- Select model
    {
        "<leader>a?",
        "<cmd>CopilotModels<CR>",
        mode = { "n" },
        desc = " Select model",
    },

    -- Select agent
    {
        "<leader>ag",
        "<cmd>CopilotAgents<CR>",
        mode = { "n" },
        desc = " Select agent",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- CHAT MANAGEMENT
    -- ══════════════════════════════════════════════════════════════════════

    -- New chat
    {
        "<leader>ac",
        "<cmd>CopilotNewChat<CR>",
        mode = { "n" },
        desc = " New chat",
    },

    -- Clear/Reset
    {
        "<leader>al",
        "<cmd>CopilotChatReset<CR>",
        mode = { "n" },
        desc = " Clear chat",
    },

    -- Stop response
    {
        "<leader>ax",
        "<cmd>CopilotChatStop<CR>",
        mode = { "n" },
        desc = " Stop response",
    },

    -- Debug info
    {
        "<leader>aD",
        "<cmd>CopilotChatDebugInfo<CR>",
        mode = { "n" },
        desc = " Debug info",
    },

    -- ══════════════════════════════════════════════════════════════════════
    -- EDIT MODE (Inline Editing)
    -- ══════════════════════════════════════════════════════════════════════

    -- Edit selection
    {
        "<leader>aE",
        "<cmd>CopilotEdit<CR>",
        mode = { "x" },
        desc = "  Edit selection",
    },
}

-- ============================================================================
-- PLUGIN RETURN
-- ============================================================================
return {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    enabled = true,
    lazy = true,
    event = { "VeryLazy" },
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
        -- Custom commands
        "CopilotQuickChat",
        "CopilotInlineChat",
        "CopilotAgent",
        "CopilotCommands",
        "CopilotContext",
        "CopilotModels",
        "CopilotAgents",
        "CopilotActions",
        "CopilotNewChat",
        "CopilotEdit",
    },
    dependencies = dependencies,
    opts = opts,
    config = config,
    keys = keys,
}
