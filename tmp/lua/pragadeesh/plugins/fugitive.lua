-- plugin dependencies
local dependencies = {}

-- plugin init function
local init = function () end

-- plugin opts
local opts = {}

-- plugin config function
local config = function (_, opts) end

-- plugin keys
local keys = {
    {
        "<leader>gs",
        mode = { "n" },
        "<cmd>Git<CR>",
        noremap = true,
        silent = true,
        desc = "open git status",
    },
    {
        "<leader>gb",
        mode = { "n" },
        "<cmd>Git blame<CR>",
        noremap = true,
        silent = true,
        desc = "open git blame",
    },
    {
        "<leader>gl",
        mode = { "n" },
        "<cmd>Git log<CR>",
        noremap = true,
        silent = true,
        desc = "open git log",
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