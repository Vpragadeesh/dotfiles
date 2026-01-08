-- plugin dependencies
local dependencies = {}

-- plugin init function
local init = function () end

-- plugin opts
local opts = {}

-- plugin config function
local config = function (_, opts) end

-- plugin keys
-- NOTE: <leader>gs and <leader>gl are used by Snacks picker (git_status, git_log)
-- Using <leader>Gs and <leader>Gl for fugitive versions to avoid conflict
local keys = {
    {
        "<leader>Gs",
        mode = { "n" },
        "<cmd>Git<CR>",
        noremap = true,
        silent = true,
        desc = "fugitive: git status",
    },
    {
        "<leader>gb",
        mode = { "n" },
        "<cmd>Git blame<CR>",
        noremap = true,
        silent = true,
        desc = "fugitive: git blame",
    },
    {
        "<leader>Gl",
        mode = { "n" },
        "<cmd>Git log<CR>",
        noremap = true,
        silent = true,
        desc = "fugitive: git log",
    },
}

-- plugin configurations
return {
    "tpope/vim-fugitive",
    version = "*",
    enabled = true,
    lazy = true,
    event = {},
    cmd = {
        "Git",
        "G",
    },
    ft = {},
    build = {},
    dependencies = dependencies,
    init = init,
    opts = opts,
    config = config,
    keys = keys,
}