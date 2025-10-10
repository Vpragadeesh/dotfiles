-- for convenience
local api = vim.api

-- plugin dependencies
local dependencies = {}

-- plugin init function
local init = function () end

-- prefer explicit node binary from nvm if available so Neovim (GUI/launcher)
-- sessions that don't source the shell rc still use the correct node.
local function find_node_cmd()
    -- helper to check file exists
    local function exists(path)
        local stat_ok, stat = pcall(function() return vim.loop.fs_stat(path) end)
        return stat_ok and stat ~= nil
    end

    -- 1) Use NVM_BIN if present
    local nvm_bin = os.getenv("NVM_BIN")
    if nvm_bin and nvm_bin ~= "" then
        local p = nvm_bin .. "/node"
        if exists(p) then
            return p
        end
    end

    -- 2) Look under common nvm directory: $NVM_DIR or $HOME/.nvm
    local nvm_dir = os.getenv("NVM_DIR") or (os.getenv("HOME") and (os.getenv("HOME") .. "/.nvm"))
    if nvm_dir and nvm_dir ~= "" then
        local glob = nvm_dir .. "/versions/node/*/bin/node"
        local matches = vim.fn.glob(glob, true, true)
        if matches and #matches > 0 then
            -- prefer the highest semver-ish version: extract vX.Y.Z and sort
            local function version_key(p)
                local v = p:match("/versions/node/(v[%d%.%-]+)") or p:match("/versions/node/([^/]+)/bin/node") or "v0"
                -- remove leading v and split
                v = v:gsub("^v", "")
                local parts = {}
                for num in v:gmatch("([%d]+)") do table.insert(parts, tonumber(num)) end
                return parts
            end

            local best
            local best_key = {}
            for _, p in ipairs(matches) do
                local kparts = version_key(p)
                local stronger = false
                if not best then
                    stronger = true
                else
                    for i = 1, math.max(#kparts, #best_key) do
                        local av = kparts[i] or 0
                        local bv = best_key[i] or 0
                        if av > bv then
                            stronger = true
                            break
                        elseif av < bv then
                            break
                        end
                    end
                end
                if stronger and exists(p) then
                    best = p
                    best_key = kparts
                end
            end
            if best then return best end
        end
    end

    -- 3) try environment hints
    local node_home = os.getenv("NODE_HOME") or os.getenv("NODE")
    if node_home and node_home ~= "" then
        local p = node_home
        if not p:match("/bin/node$") then
            p = p .. "/bin/node"
        end
        if exists(p) then
            return p
        end
    end

    -- 4) fallback to 'node' on PATH
    return "node"
end

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
    copilot_node_command = find_node_cmd(),
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
