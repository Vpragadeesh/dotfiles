-- for convenience
local api = vim.api

-- plugin dependencies
local dependencies = {}

-- plugin init function
local init = function () end

-- plugin opts
local opts = {
    panel = {
        enabled = false,
    },
    suggestion = {
        enabled = false,
    },
    filetypes = {
        ["*"] = true,
        yaml = true,
        markdown = true,
        help = false,
        gitcommit = true,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        ["."] = false,
    },
    copilot_node_command = "node",
    server_opts_overrides = {},
}

-- plugin config function
local config = function (_, opts)
    require("copilot").setup(opts)
end

-- plugin keys
local keys = {}

-- plugin configurations
return {
    "zbirenbaum/copilot.lua",
    version = "*",
    enabled = true,
    lazy = true,
    event = {
        "InsertEnter",
    },
    cmd = {
        "Copilot",
    },
    ft = {},
    build = {},
    dependencies = dependencies,
    init = init,
    opts = opts,
    config = config,
    keys = keys,
}
