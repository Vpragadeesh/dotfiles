-- for convenience
local keymap = vim.keymap

keymap.set({ "n" }, "<localleader>fo", "zo", {
    noremap = true,
    silent = true,
    desc = "open the folds",
})

keymap.set({ "n" }, "<localleader>fc", "zc", {
    noremap = true,
    silent = true,
    desc = "close the folds",
})

keymap.set({ "n" }, "<localleader>fO", "zR", {
    noremap = true,
    silent = true,
    desc = "open all folds",
})

keymap.set({ "n" }, "<localleader>fC", "zM", {
    noremap = true,
    silent = true,
    desc = "close all folds",
})

keymap.set({ "n" }, "<leader>cl", "<cmd>Lazy<CR>", {
    noremap = true,
    silent = true,
    desc = "open lazy.nvim",
})

keymap.set({ "i" }, "jj", "<ESC>", {
    noremap = true,
    silent = true,
    desc = "exit insert mode with jj",
})

keymap.set({ "t" }, "<C-e>", "<C-\\><C-n>", {
    noremap = true,
    silent = true,
    desc = "exit terminal mode",
})

keymap.set({ "n", "x" }, "<leader>cs", "<cmd>nohlsearch<CR>", {
    noremap = true,
    silent = true,
    desc = "clear search highlights",
})

keymap.set({ "n", "x" }, "=", "<C-a>", {
    noremap = true,
    silent = true,
    desc = "increment number",
})

keymap.set({ "n", "x" }, "-", "<C-x>", {
    noremap = true,
    silent = true,
    desc = "decrement number",
})

keymap.set({ "n", "x" }, "<C-w>\\", "<C-w>v", {
    noremap = true,
    silent = true,
    desc = "split window vertically",
})

keymap.set({ "n", "x" }, "<C-w>-", "<C-w>s", {
    noremap = true,
    silent = true,
    desc = "split window horizontally",
})

keymap.set({ "n", "x" }, "<C-w>=", "<C-w>=", {
    noremap = true,
    silent = true,
    desc = "make splits equal size",
})

keymap.set({ "n", "x" }, "<C-up>", "<cmd>horizontal resize +2<CR>", {
    noremap = true,
    silent = true,
    desc = "increase the window height",
})

keymap.set({ "n", "x" }, "<C-down>", "<cmd>horizontal resize -2<CR>", {
    noremap = true,
    silent = true,
    desc = "decrease the window height",
})

keymap.set({ "n", "x" }, "<C-left>", "<cmd>vertical resize -2<CR>", {
    noremap = true,
    silent = true,
    desc = "decrease the window width",
})

keymap.set({ "n", "x" }, "<C-right>", "<cmd>vertical resize +2<CR>", {
    noremap = true,
    silent = true,
    desc = "increase the window width",
})

keymap.set({ "x" }, "<", "<gv", {
    noremap = true,
    silent = true,
    desc = "keep visual mode selection after indenting",
})

keymap.set({ "x" }, ">", ">gv", {
    noremap = true,
    silent = true,
    desc = "keep visual mode selection after indenting",
})

keymap.set({ "n", "x" }, "x", [["_x]], {
    noremap = true,
    silent = true,
    desc = "do not copy on x",
})

keymap.set({ "x" }, "p", [["_dP]], {
    noremap = true,
    silent = true,
    desc = "do not copy on paste",
})

keymap.set({ "n", "x" }, "<leader>d", [["_d]], {
    noremap = true,
    silent = true,
    desc = "do not copy on delete",
})

keymap.set({ "n", "x" }, "j", [[v:count == 0 ? "gj" : "j"]], {
    noremap = true,
    silent = true,
    expr = true,
    desc = "move down through the visual line",
})

keymap.set({ "n", "x" }, "k", [[v:count == 0 ? "gk" : "k"]], {
    noremap = true,
    silent = true,
    expr = true,
    desc = "move up through the visual line",
})

keymap.set({ "n", "x" }, "<leader>ww", "<cmd>set wrap!<CR>", {
    noremap = true,
    silent = true,
    desc = "toggle word wrap",
})

keymap.set({ "i", "c" }, "<C-n>", "<NOP>", {
    noremap = true,
    silent = true,
    desc = "hide omni completion",
})

keymap.set({ "i", "c" }, "<C-p>", "<NOP>", {
    noremap = true,
    silent = true,
    desc = "hide omni completion",
})

keymap.set({ "c" }, "<Tab>", "<NOP>", {
    noremap = true,
    silent = true,
    desc = "hide omni completion",
})

keymap.set({ "c" }, "<S-Tab>", "<NOP>", {
    noremap = true,
    silent = true,
    desc = "hide omni completion",
})

keymap.set({ "c" }, "<C-d>", "<NOP>", {
    noremap = true,
    silent = true,
    desc = "hide omni completion",
})

keymap.set({ "i" }, "<C-x>", "<NOP>", {
    noremap = true,
    silent = true,
    nowait = true,
    desc = "hide omni completion",
})

keymap.set({ "i", "s" }, "<Tab>", "<Tab>", {
    noremap = true,
    silent = true,
    desc = "overwrite the jump to next snippet",
})

keymap.set({ "i", "s" }, "<S-Tab>", "<S-Tab>", {
    noremap = true,
    silent = true,
    desc = "overwrite the jump to previous snippet",
})

-- git keymaps
keymap.set({ "n" }, "<leader>ggo", function ()
    require("snacks").lazygit.open()
end, {
    noremap = true,
    silent = true,
    desc = "open lazygit",
})

keymap.set({ "n" }, "<leader>ggl", function ()
    require("snacks").lazygit.log()
end, {
    noremap = true,
    silent = true,
    desc = "open lazygit with log view",
})

keymap.set({ "n" }, "<leader>ggf", function ()
    require("snacks").lazygit.log_file()
end, {
    noremap = true,
    silent = true,
    desc = "open lazygit with the log of the current file",
})

keymap.set({ "n" }, "<leader>gbl", function ()
    require("snacks").git.blame_line()
end, {
    noremap = true,
    silent = true,
    desc = "blame the current line",
})

keymap.set({ "n" }, "<leader>gB", function ()
    require("snacks").picker.git_branches({
        all = true,
    })
end, {
    noremap = true,
    silent = true,
    desc = "find the git branches",
})

keymap.set({ "n", "x" }, "<leader>go", function ()
    require("snacks").gitbrowse.open()
end, {
    noremap = true,
    silent = true,
    desc = "open the current buffer in the browser",
})

keymap.set({ "n" }, "<leader>gl", function ()
    require("snacks").picker.git_log()
end, {
    noremap = true,
    silent = true,
    desc = "find the git log",
})

-- NOTE: Removed duplicate <leader>op keymap (oh-my-posh theme)
-- Use <leader>oP if you need it back
keymap.set({ "n" }, "<leader>gL", function ()
    require("snacks").picker.git_log_line()
end, {
    noremap = true,
    silent = true,
    desc = "find the git log for the current line",
})

keymap.set({ "n" }, "<leader>gf", function ()
    require("snacks").picker.git_log_file()
end, {
    noremap = true,
    silent = true,
    desc = "find the git log for the current file",
})

keymap.set({ "n" }, "<leader>gs", function ()
    require("snacks").picker.git_status()
end, {
    noremap = true,
    silent = true,
    desc = "find the git status",
})

keymap.set({ "n" }, "<leader>gS", function ()
    require("snacks").picker.git_stash()
end, {
    noremap = true,
    silent = true,
    desc = "find the git stash",
})

keymap.set({ "n" }, "<leader>gd", function ()
    require("snacks").picker.git_diff()
end, {
    noremap = true,
    silent = true,
    desc = "find the git diff",
})

-- open a vertical terminal (uses configured `shell`, e.g. fish)
keymap.set({ "n" }, "<leader>vt", function ()
    vim.cmd("vsplit")
    vim.cmd("terminal")
end, {
    noremap = true,
    silent = true,
    desc = "open vertical terminal",
})

return {}
