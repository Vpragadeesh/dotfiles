# Neovim Keybindings Reference (project)

> Auto-generated from the repository (lua/**) — contains global mappings, plugin keymaps, and user commands.

---

## Quick notes ✅

- Leader key: `\<leader>` (user-defined; default is `\`).
- Localleader: `\<localleader>`.
- Modes: `n` = normal, `i` = insert, `v` = visual, `x` = visual, `o` = operator, `t` = terminal, `c` = cmdline, blank = plugin-specific or unset.

---

## Table of contents

1. Global mappings (core) ✅
2. Copilot & CopilotChat (Agent) 🔧
3. LSP (nvim-lspconfig) 🧭
4. Snacks (core utility picker) 🔎
5. Harpoon (quick file nav) 📌
6. Fugitive (git) 🧾
7. Trouble (lists) ⚠️
8. Flash (jumping) ⚡
9. Navigator (mux pane navigation) 🧭
10. Other plugin mappings (Oil, Mason, Todo, Mini, Blink) 🔧
11. User commands (Copilot & others) 🧰

---

## 1) Global mappings (from `lua/pragadeesh/configs/keymaps.lua`) ✅

| Key | Mode | Action / Command | Description |
|-----|------|------------------|-------------|
| `<localleader>fo` | n | `zo` | Open folds |
| `<localleader>fc` | n | `zc` | Close folds |
| `<localleader>fO` | n | `zR` | Open all folds |
| `<localleader>fC` | n | `zM` | Close all folds |
| `<leader>cl` | n | `<cmd>Lazy<CR>` | Open lazy.nvim |
| `jj` | i | `<ESC>` | Exit insert mode with jj |
| `<C-e>` | t | `<C-\><C-n>` | Exit terminal mode |
| `<leader>cs` | n,x | `<cmd>nohlsearch<CR>` | Clear search highlights |
| `=` | n,x | `<C-a>` | Increment number |
| `-` | n,x | `<C-x>` | Decrement number |
| `<C-w>\` | n,x | `<C-w>v` | Split window vertically |
| `<C-w>-` | n,x | `<C-w>s` | Split window horizontally |
| `<C-w>=` | n,x | `<C-w>=` | Make splits equal size |
| `<C-up>` / `<C-down>` / `<C-left>` / `<C-right>` | n,x | `resize` cmds | Resize windows |
| `<` / `>` | x | `<gv` / `>gv` | Keep visual selection after indenting |
| `x` | n,x | `"_x` | Do not copy on x |
| `p` | x | `"_dP` | Do not copy on paste |
| `<leader>d` | n,x | `"_d` | Do not copy on delete |
| `j` / `k` | n,x (expr) | wrap-aware motion | Move by visual line when no count |
| `<leader>ww` | n,x | `<cmd>set wrap!<CR>` | Toggle word wrap |

---

## 2) Copilot & CopilotChat (Agent) 🔧

### Inline copilot suggestions (config + keymaps)
| Key | Mode | Action | Notes |
|-----|------|--------|-------|
| `<Tab>` | i | Accept Copilot suggestion if visible; else send Tab | Implemented in `keymaps.lua` (VS Code style)
| `<C-y>` | i | Alternative Copilot accept; fallback to key | Insert-mode alternative accept
| `<M-w>` | suggestion key (copilot) | accept_word | From `copilot.lua` config
| `<M-l>` | suggestion key | accept_line |
| `<M-]>` / `<M-[>` | suggestion navigation | next / prev |

### Copilot Chat / Agent keybindings (from `lua/pragadeesh/plugins/copilotchat.lua`)
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-S-i>` | n,x | `<cmd>CopilotChatToggle<CR>` | Toggle chat panel (VS Code style) |
| `<leader>ai` / `<leader>at` | n,x | `<cmd>CopilotChatToggle<CR>` | Toggle chat panel |
| `<C-i>` | n | `<cmd>CopilotQuickChat<CR>` | Quick chat input |
| `<C-i>` | x | `<cmd>CopilotInlineChat<CR>` | Inline edit selection |
| `<leader>aa` | n,x | `<cmd>CopilotQuickChat<CR>` / `<cmd>CopilotInlineChat<CR>` | Quick ask / ask about selection |
| `<leader>ae` | n,x | `/Explain` | /explain slash command |
| `<leader>af` | n,x | `/Fix` | /fix slash command |
| `<leader>aT` | x | `/Tests` | /tests command for selection |
| `<leader>aw` | n | `<cmd>CopilotAgent<CR>` | Agent @workspace mode |
| `<leader>a/` | n,x | `<cmd>CopilotCommands<CR>` | Slash command picker |
| `<leader>a@` | n | `<cmd>CopilotContext<CR>` | Context picker (@) |
| `<leader>ap` | n,x | `<cmd>CopilotActions<CR>` | Quick actions picker |
| `<leader>a?` | n | `<cmd>CopilotModels<CR>` | Model selector |
| `<leader>ag` | n | `<cmd>CopilotAgents<CR>` | Agent selector |
| `<leader>ac` | n | `<cmd>CopilotNewChat<CR>` | New chat |
| `<leader>al` | n | `<cmd>CopilotChatReset<CR>` | Clear chat |
| `<leader>ax` | n | `<cmd>CopilotChatStop<CR>` | Stop response |

User commands: `:CopilotQuickChat`, `:CopilotInlineChat`, `:CopilotAgent`, `:CopilotCommands`, `:CopilotContext`, `:CopilotModels`, `:CopilotAgents`, `:CopilotActions`, `:CopilotNewChat`, `:CopilotEdit`

> Note: Copilot inline suggestion keys are configured in `lua/pragadeesh/configs/keymaps.lua` and `lua/pragadeesh/plugins/copilot.lua`.

---

## 3) LSP keybindings (from `lua/pragadeesh/plugins/lspconfig.lua`) 🧭
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `gd` | n | `Snacks.picker.lsp_definitions()` | Go to definitions |
| `gD` | n | `Snacks.picker.lsp_declarations()` | Go to declarations |
| `gt` | n | `Snacks.picker.lsp_type_definitions()` | Type definitions |
| `gri` | n | `Snacks.picker.lsp_implementations()` | Implementations |
| `grr` | n | `Snacks.picker.lsp_references()` | References |
| `gra` | n | `lsp.buf.code_action()` | LSP code action |
| `grn` | n | `lsp.buf.rename()` | Rename |
| `grN` | n | `Snacks.rename.rename_file()` | File rename |
| `<leader>lc` | n | `Snacks.picker.lsp_config()` | LSP server config |
| `<leader>li` | n | `:LspInfo` | LSP server info |
| `<leader>lr` | n | `:LspRestart` | Restart LSP |
| `<leader>ll` | n | `:LspLog` | LSP log |
| `<leader>ls` | n | `Snacks.picker.lsp_symbols()` | Buffer symbols |
| `<leader>lS` | n | `Snacks.picker.lsp_workspace_symbols()` | Workspace symbols |
| `K` | n | `lsp.buf.hover()` | Hover |
| `gK` | n | `lsp.buf.signature_help()` | Signature help |
| `<C-w>d` / `<C-w><C-d>` | n | `diagnostic.open_float()` | Show diagnostic under cursor |
| `]d` / `[d` | n | `diagnostic.jump` | Jump next / prev diagnostic |
| `]r` / `[r` | n | reference jump next / prev |
| `<leader>lt` | n | `toggle_lsp()` | Toggle LSP servers |

---

## 4) Snacks (picker) 🔎
Snacks is heavily mapped. Highlights:

| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>fb` | n | `Snacks.picker.buffers()` | Find open buffers |
| `<leader>ff` | n | `Snacks.picker.files()` | Find files (cwd) |
| `<leader>fg` | n | `Snacks.picker.git_files()` | Find files in git repo |
| `<leader>fs` | n | `Snacks.picker.smart()` | Smart picker |
| `<leader>sg` | n | `Snacks.picker.grep()` | Search in cwd (live) |
| `<leader>sk` | n | `Snacks.picker.keymaps()` | Search for keymaps |
| `<leader>ee` | n | `Snacks.explorer.open()` | Open snacks explorer |
| `<C-x>` | n | `Snacks.terminal.toggle("fish")` | Toggle terminal |

(There are many more Snacks mappings — they are listed under `keys` in `lua/pragadeesh/plugins/snacks.lua`.)

---

## 5) Harpoon (quick file nav) 📌
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>a` | n | Add file to harpoon list |
| `<C-s>` | n | Toggle quick menu |
| `<leader>hj` / `<leader>hk` | n | Next / previous harpoon file |
| `<leader>1` .. `<leader>9` | n | Jump to harpoon file 1..9 |
| `<leader>0` | n | Jump to harpoon file 10 |

---

## 6) Fugitive (git) 🧾
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>Gs` | n | `<cmd>Git<CR>` | Fugitive git status |
| `<leader>gb` | n | `<cmd>Git blame<CR>` | Git blame |
| `<leader>Gl` | n | `<cmd>Git log<CR>` | Git log |

---

## 7) Trouble (lists) ⚠️
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<leader>xx` / `<leader>xX` | n | Toggle diagnostics (workspace / buffer) |
| `<leader>xs` / `<leader>xS` | n | Toggle symbols / lsp symbols |
| `<leader>xl` / `<leader>xL` | n | Toggle LSP / loclist |
| `<leader>xq` | n | Toggle qflist |
| `]q` | n | Jump to next trouble / quickfix |

---

## 8) Flash (jump) ⚡
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `,fa` | n,x,o | `flash.jump` (two-stage) | Flash jumping UI |
| `,fs` | n,x,o | `flash.jump` (search trigger `,`) | Jump via search |
| `,fS` / `,ft` / `,fw` / `,fl` | n,x,o | Treesitter / word / start-of-line jumps |

---

## 9) Navigator (mux pane movement) 🧭
| Key | Mode | Action | Description |
|-----|------|--------|-------------|
| `<C-h>` / `<C-l>` / `<C-j>` / `<C-k>` / `<C-\>` | (plugin) | Move mux panes (Navigator) | Pane navigation (tmux integration)

> Note: Some terminals / tmux can conflict (`<C-j>` etc.). Conflict-conscious fallback mappings were added for Copilot accept (`<C-y>`).

---

## 10) Other plugin & helper mappings 🔧
- Oil.nvim: `<leader>ef` — open parent directory (file browser)
- Mason: `<leader>cm` — open Mason window
- Todo-comments: `<leader>st`, `]t`, `[t` — search / jump todos
- Mini.*: many sub-mappings available in `mini` options (e.g., surround: `,sa`, `,sd`, move: `<M-h>` / `<M-l>` etc.)
- Blink (completion keymap): `<C-space>`, `<C-s>`, `<C-e>`, `<C-y>`, `<C-k>`, `<C-p>`, `<C-n>`, `<Tab>`, `<S-Tab>`, `<C-d>`, `<C-b>`, `<C-f>` (see `blink.cmp` config in `lua/pragadeesh/plugins/blink.lua`)

---

## 11) User commands (notable) 🧰
- `:CopilotQuickChat` — Quick ask (buffer)
- `:CopilotInlineChat` — Inline chat with visual selection
- `:CopilotAgent` — Agent with workspace context (@workspace)
- `:CopilotCommands` — Slash commands picker (/)
- `:CopilotContext` — Context picker (@)
- `:CopilotModels` / `:CopilotAgents` — Model / agent selectors
- `:CopilotActions` — Quick actions picker
- `:CopilotNewChat` — Start a fresh chat
- `:CopilotEdit` — Edit selection (inline)
- `:Mason` — Open Mason
- `:TodoQuickFix` / `:TodoTrouble` — Todo utilities

---

## How to use
1. Restart Neovim after pulling these changes so lazy-loaded plugin keymaps are registered.
2. Use `<leader>` + the shown keys in normal/visual mode to invoke actions.
3. For Copilot: use `<Tab>` (or `<C-y>` fallback) in insert mode to accept inline suggestions.

---

## Notes / Conflicts ⚠️
- `<C-j>` is used by Navigator for tmux pane navigation — avoid using it as a global accept key in tmux & kitty; an alternate Copilot accept mapping (`<C-y>`) exists.
- Duplicate mappings were addressed earlier (e.g., `fugitive` remapped to `<leader>G*` to avoid clashes with `snacks`).

---

If you'd like, I can:
- Expand the document to include all Snacks mappings verbatim, or
- Generate a `neovim-keybinding-short.md` with only high-priority mappings for quick reference.

---

*Generated on 2026-01-13.*
