# Duplicate Keybindings Report

**Progress update (2026-01-13 12:55 UTC):**
- ✅ Removed duplicate plugin keymaps from `lua/pragadeesh/plugins/copilotchat.lua` (plugin-level `keys` block and the `<Tab>` / submit mappings) and `lua/pragadeesh/plugins/avante.lua` (removed disabled plugin `keys`).
- ✅ This eliminates several duplicates such as `<leader>aa`, `<leader>ai`, `<leader>aw`, `<leader>at`, and the plugin-local `<Tab>` mapping. The central keymaps in `lua/pragadeesh/configs/keymaps.lua` are now the canonical source.
- ℹ️ Remaining duplicates are still listed below; if you want I can continue removing or propose non-conflicting remaps.

Found **(reduced)** duplicated key strings. The sections below show remaining duplicates and their current locations.

## `<C-y>` — 4 occurrences (reduced)
- lua/pragadeesh/plugins/blink.lua : L19 — `["<C-y>"] = {},`
- lua/pragadeesh/plugins/oil.lua : L68 — `["<C-y>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L332 — `keymap.set({ "i" }, "<C-y>", function()`
- lua/pragadeesh/configs/keymaps.lua : L339 — `vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-y>', true, false, true), 'n', true)`

## `<CR>` — 5 occurrences (reduced)
- lua/pragadeesh/plugins/avante.lua : L87 — `normal = "<CR>",`
- lua/pragadeesh/plugins/mason.lua : L38 — `toggle_package_expand = "<CR>",`
- lua/pragadeesh/plugins/mason.lua : L47 — `toggle_package_install_log = "<CR>",`
- lua/pragadeesh/configs/keymaps.lua : L369 — `vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<CR>', true, false, true), 'n', true)`
- lua/pragadeesh/configs/keymaps.lua : L376 — `vim.keymap.set("i", "<C-k>", "<CR>", { buffer = true, noremap = true, silent = true, desc = "Confirm picker selection" })`

## `<NOP>` — 6 occurrences
- lua/pragadeesh/configs/keymaps.lua : L156 — `keymap.set({ "i", "c" }, "<C-n>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L162 — `keymap.set({ "i", "c" }, "<C-p>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L168 — `keymap.set({ "c" }, "<Tab>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L174 — `keymap.set({ "c" }, "<S-Tab>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L180 — `keymap.set({ "c" }, "<C-d>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L186 — `keymap.set({ "i" }, "<C-x>", "<NOP>", {`

## `<M-l>` — 5 occurrences
- lua/pragadeesh/plugins/mini.lua : L98 — `right = "<M-l>",`
- lua/pragadeesh/plugins/mini.lua : L102 — `line_right = "<M-l>",`
- lua/pragadeesh/plugins/mini.lua : L472 — `"<M-l>",`
- lua/pragadeesh/plugins/copilot.lua : L102 — `accept_line = "<M-l>",`
- lua/pragadeesh/plugins/avante.lua : L77 — `accept = "<M-l>",`

## `<S-Tab>` — 5 occurrences
- lua/pragadeesh/plugins/blink.lua : L42 — `["<S-Tab>"] = {},`
- lua/pragadeesh/plugins/avante.lua : L92 — `reverse_switch_windows = "<S-Tab>",`
- lua/pragadeesh/configs/keymaps.lua : L174 — `keymap.set({ "c" }, "<S-Tab>", "<NOP>", {`
- lua/pragadeesh/configs/keymaps.lua : L199 — `keymap.set({ "i", "s" }, "<S-Tab>", "<S-Tab>", {`
- lua/pragadeesh/configs/keymaps.lua : L199 — `keymap.set({ "i", "s" }, "<S-Tab>", "<S-Tab>", {`

## `<C-k>` — 4 occurrences
- lua/pragadeesh/plugins/navigator.lua : L56 — `"<C-k>",`
- lua/pragadeesh/plugins/blink.lua : L20 — `["<C-k>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L368 — `keymap.set({ "n" }, "<C-k>", function()`
- lua/pragadeesh/configs/keymaps.lua : L376 — `vim.keymap.set("i", "<C-k>", "<CR>", { buffer = true, noremap = true, silent = true, desc = "Confirm picker selection" })`

## `<C-l>` — 4 occurrences
- lua/pragadeesh/plugins/navigator.lua : L30 — `"<C-l>",`
- lua/pragadeesh/plugins/copilotchat.lua : L204 — `normal = "<C-l>",`
- lua/pragadeesh/plugins/copilotchat.lua : L205 — `insert = "<C-l>",`
- lua/pragadeesh/plugins/oil.lua : L74 — `["<C-l>"] = {},`

## `<C-s>` — 4 occurrences
- lua/pragadeesh/plugins/blink.lua : L13 — `["<C-s>"] = {`
- lua/pragadeesh/plugins/harpoon.lua : L45 — `"<C-s>",`
- lua/pragadeesh/plugins/avante.lua : L88 — `insert = "<C-s>",`
- lua/pragadeesh/plugins/oil.lua : L60 — `["<C-s>"] = {},`

## `<C-x>` — 4 occurrences
- lua/pragadeesh/plugins/snacks.lua : L813 — `"<C-x>",`
- lua/pragadeesh/plugins/oil.lua : L61 — `["<C-x>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L58 — `keymap.set({ "n", "x" }, "-", "<C-x>", {`
- lua/pragadeesh/configs/keymaps.lua : L186 — `keymap.set({ "i" }, "<C-x>", "<NOP>", {`

## `<M-j>` — 4 occurrences
- lua/pragadeesh/plugins/flash.lua : L325 — `["<M-j>"] = {`
- lua/pragadeesh/plugins/mini.lua : L99 — `down = "<M-j>",`
- lua/pragadeesh/plugins/mini.lua : L103 — `line_down = "<M-j>",`
- lua/pragadeesh/plugins/mini.lua : L484 — `"<M-j>",`

## `<C-space>` — 3 occurrences
- lua/pragadeesh/plugins/blink.lua : L9 — `["<C-space>"] = {`
- lua/pragadeesh/plugins/treesitter.lua : L64 — `init_selection = "<C-space>",`
- lua/pragadeesh/plugins/treesitter.lua : L65 — `node_incremental = "<C-space>",`

## `<M-h>` — 3 occurrences
- lua/pragadeesh/plugins/mini.lua : L97 — `left = "<M-h>",`
- lua/pragadeesh/plugins/mini.lua : L101 — `line_left = "<M-h>",`
- lua/pragadeesh/plugins/mini.lua : L460 — `"<M-h>",`

## `<M-k>` — 3 occurrences
- lua/pragadeesh/plugins/mini.lua : L100 — `up = "<M-k>",`
- lua/pragadeesh/plugins/mini.lua : L104 — `line_up = "<M-k>",`
- lua/pragadeesh/plugins/mini.lua : L496 — `"<M-k>",`

## `<cmd>CopilotQuickChat<CR>` — 1 occurrence (reduced)
- lua/pragadeesh/configs/keymaps.lua : L360 — `keymap.set({ "n", "x" }, "<leader>aa", "<cmd>CopilotQuickChat<CR>", {`

## `<C-]>` — 2 occurrences
- lua/pragadeesh/plugins/copilot.lua : L105 — `dismiss = "<C-]>",`
- lua/pragadeesh/plugins/avante.lua : L80 — `dismiss = "<C-]>",`

## `<C-c>` — 2 occurrences
- lua/pragadeesh/plugins/copilotchat.lua : L201 — `insert = "<C-c>",`
- lua/pragadeesh/plugins/mason.lua : L45 — `cancel_installation = "<C-c>",`

## `<C-d>` — 2 occurrences
- lua/pragadeesh/plugins/blink.lua : L43 — `["<C-d>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L180 — `keymap.set({ "c" }, "<C-d>", "<NOP>", {`

## `<C-e>` — 2 occurrences
- lua/pragadeesh/plugins/blink.lua : L16 — `["<C-e>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L40 — `keymap.set({ "t" }, "<C-e>", "<C-\\><C-n>", {`

## `<C-f>` — 2 occurrences
- lua/pragadeesh/plugins/blink.lua : L38 — `["<C-f>"] = {`
- lua/pragadeesh/plugins/mason.lua : L46 — `apply_language_filter = "<C-f>",`

## `<C-h>` — 2 occurrences
- lua/pragadeesh/plugins/navigator.lua : L17 — `"<C-h>",`
- lua/pragadeesh/plugins/oil.lua : L67 — `["<C-h>"] = {},`

## `<C-i>` — 2 occurrences
- lua/pragadeesh/plugins/copilotchat.lua : L521 — `"<C-i>",`
- lua/pragadeesh/plugins/copilotchat.lua : L529 — `"<C-i>",`

## `<C-n>` — 2 occurrences
- lua/pragadeesh/plugins/blink.lua : L27 — `["<C-n>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L156 — `keymap.set({ "i", "c" }, "<C-n>", "<NOP>", {`

## `<C-p>` — 2 occurrences
- lua/pragadeesh/plugins/blink.lua : L23 — `["<C-p>"] = {`
- lua/pragadeesh/configs/keymaps.lua : L162 — `keymap.set({ "i", "c" }, "<C-p>", "<NOP>", {`

## `<C-w>=` — 2 occurrences
- lua/pragadeesh/configs/keymaps.lua : L76 — `keymap.set({ "n", "x" }, "<C-w>=", "<C-w>=", {`
- lua/pragadeesh/configs/keymaps.lua : L76 — `keymap.set({ "n", "x" }, "<C-w>=", "<C-w>=", {`

## `<M-[>` — 2 occurrences
- lua/pragadeesh/plugins/copilot.lua : L104 — `prev = "<M-[>",`
- lua/pragadeesh/plugins/avante.lua : L79 — `prev = "<M-[>",`

## `<M-]>` — 2 occurrences
- lua/pragadeesh/plugins/copilot.lua : L103 — `next = "<M-]>",`
- lua/pragadeesh/plugins/avante.lua : L78 — `next = "<M-]>",`

## `<Up>` — 2 occurrences
- lua/pragadeesh/utils/mini.lua : L64 — `return "`\n```" .. api.nvim_replace_termcodes("<Up>", true, true, true)`
- lua/pragadeesh/plugins/blink.lua : L31 — `["<Up>"] = {},`

## `<cmd>CopilotAgent<CR>` — 1 occurrence (reduced)
- lua/pragadeesh/configs/keymaps.lua : L348 — `keymap.set({ "n" }, "<leader>aw", "<cmd>CopilotAgent<CR>", {`

(Removed plugin-level duplicate entries for `CopilotInlineChat`; only command registrations remain.)

## `<leader>ae` — 1 occurrence (reduced)
- lua/pragadeesh/plugins/avante.lua : L146 — `"<leader>ae",`

## `<leader>ao` — 1 occurrence (reduced)
- lua/pragadeesh/plugins/avante.lua : L156 — `"<leader>ao",`

## `<leader>ar` — 1 occurrence (reduced)
- lua/pragadeesh/plugins/avante.lua : L136 — `"<leader>ar",`

