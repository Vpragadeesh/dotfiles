-- cyberpunk / cyber-dark colorscheme plugin
local cmd = vim.cmd

-- plugin dependencies
local dependencies = {
    {
        "nvim-tree/nvim-web-devicons",
    },
}

-- plugin init function
local init = function ()
    -- ensure colorscheme loads without error
    pcall(function()
        cmd("colorscheme tokyonight")
    end)
end

-- plugin opts
local opts = {}

-- plugin keys (toggle theme)
local keys = {
    {
        "<leader>ct",
        mode = { "n" },
        function ()
            local cs = vim.g.colors_name or ""
            if cs == "kanagawa" then
                cmd("colorscheme tokyonight")
            else
                cmd("colorscheme kanagawa")
            end
        end,
        noremap = true,
        silent = true,
        desc = "toggle colorscheme kanagawa/tokyonight",
    },
}

-- plugin specification
return {
    "rebelot/kanagawa.nvim",
    version = "*",
    enabled = true,
    lazy = false,
    priority = 1000,
    dependencies = dependencies,
    init = init,
    opts = opts,
    keys = keys,
}
