# Neovim setup

Personal Neovim config: a [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
fork with Claude Code integration, git review tooling, and settings carried
over from the old pathogen-era vimrc.

Kickstart's own documentation is still in `README.md`. This file covers
setting the config up on a new machine.

## Architecture

- **Neovim 0.12+**, not classic Vim. The config uses the built-in `vim.pack`
  plugin manager, so there is no lazy.nvim or pathogen.
- **Single readable `init.lua`** in numbered sections, plus personal additions
  under `lua/custom/plugins/`.
- **Terminal-first AI**: Claude Code runs in a terminal;
  [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim) bridges it
  to Neovim over the same WebSocket protocol as the official VS Code
  extension. Selection context flows out, proposed edits come back as native
  diffs.
- **No ghost-text completion** (no Copilot). LSP completion only.
- Leader is Space; discoverability via which-key.

## Fresh machine setup

### 1. Prerequisites

macOS with Homebrew, and the `claude` CLI installed (the bridge needs it).

```sh
brew install neovim ripgrep fd fzf lazygit git-delta tree-sitter-cli
```

Two gotchas learned the hard way:

- Install **`tree-sitter-cli`**, not `tree-sitter`. The `tree-sitter` formula
  is library-only and parser compilation fails with `ENOENT: 'tree-sitter'`.
- Real ripgrep must be on PATH for Telescope. A shell function shimming `rg`
  to something else does not count.

Confirm `nvim --version` reports **0.12 or newer** — `vim.pack` does not exist
before 0.12.

### 2. Terminal and font

Ghostty ships Nerd Font glyphs, so `vim.g.have_nerd_font = true` (Section 1)
works out of the box. On another terminal, either install a Nerd Font
(`brew install --cask font-jetbrains-mono-nerd-font`, then select it) or set
that flag to `false`.

### 3. Clone

**If `~/.config/nvim` already exists, back it up with a rename — never
delete.** Same for `~/.local/share/nvim` and `~/.local/state/nvim`.

```sh
ts=$(date +%Y%m%d-%H%M%S)
for p in ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim; do
  [ -e "$p" ] && mv "$p" "$p.bak.$ts"
done

git clone https://github.com/jmejia/vim.git ~/.config/nvim
```

To keep the option of merging upstream kickstart changes later:

```sh
cd ~/.config/nvim
git remote add upstream https://github.com/nvim-lua/kickstart.nvim.git
```

### 4. Language servers

Nothing to adjust: every machine runs the identical config (see "One config,
every machine" below). Mason installs the full server set in the next step.

### 5. Install everything

Plugins install synchronously on first boot. Mason and treesitter are async by
default, so they need explicit sync nudges — a headless quit would otherwise
kill them mid-install.

```sh
# 1. First boot installs all vim.pack plugins (takes a minute)
nvim --headless "+lua print('BOOT OK')" +qa!

# 2. Second boot should print BOOT OK with no errors
nvim --headless "+lua print('BOOT OK')" +qa!

# 3. Language servers and formatters
nvim --headless "+MasonToolsInstallSync" +qa!

# 4. Treesitter parsers (match this list to `parsers` in Section 9)
nvim --headless "+lua require('nvim-treesitter').install({'bash','c','diff','html','lua','luadoc','markdown','markdown_inline','query','vim','vimdoc','python','toml','csv','sql','ruby','embedded_template','javascript','typescript','tsx','css','scss','json','yaml','dockerfile'}):wait(300000)" +qa!
```

### 6. Verify

```sh
nvim --headless \
  "+lua io.write('PARSERS: ' .. table.concat(require('nvim-treesitter').get_installed('parsers'), ' ') .. '\n')" \
  "+lua io.write('CLAUDE: ' .. tostring(vim.fn.exists(':ClaudeCode') == 2) .. ' OIL: ' .. tostring(vim.fn.exists(':Oil') == 2) .. ' DIFFVIEW: ' .. tostring(vim.fn.exists(':DiffviewOpen') == 2) .. ' FUGITIVE: ' .. tostring(vim.fn.exists(':G') == 2) .. '\n')" \
  +qa!

ls ~/.local/share/nvim/mason/bin/
```

Expect all parsers listed, all four commands `true`, and Mason's bin directory
holding the servers from Section 6 plus `prettierd`.

Then open `nvim` in a real repo and run `:checkhealth`. Warnings about
optional providers (perl, ruby provider, wget, Go, cargo, luarocks) are fine;
errors are not. The `blink_cmp_fuzzy lib is not downloaded/built` warning is
also expected — kickstart sets `fuzzy = { implementation = 'lua' }` on
purpose to avoid requiring a Rust toolchain.

## One config, every machine

The machines run different stacks (personal: Python + Ruby; work: Ruby +
TypeScript/React), but the config enables the **union** of all of it
everywhere. LSP servers, formatters, and parsers only activate for matching
filetypes, so an unused stack costs nothing beyond its one-time Mason
install. In exchange, the tracked files never need per-machine edits and
`git pull` is the whole sync story.

If a genuinely machine-specific override is ever needed, add an untracked
`lua/custom/plugins/local.lua` (gitignored): `lua/custom/plugins/init.lua`
auto-loads every `.lua` file in that directory.

## Python and `uv`

`uv` keeps a project's packages in a local `.venv` that is **not** on PATH.
basedpyright is configured (Section 6, `before_init`) to find the workspace
`.venv/bin/python` and use it, so third-party imports resolve. Without that
hook every `import polars` and the like would be flagged as unresolved.

Type checking is deliberately set to `basic`. `uv run mypy .` is the authority
in the project pipeline; two full-strength type checkers disagreeing produces
squiggles CI does not care about, and vice versa.

## Two file explorers, on purpose

They solve different problems and coexist happily.

- **neo-tree** (`\`) — the NERDTree/VS Code-style sidebar. A persistent tree
  for *seeing* project structure and orienting in unfamiliar code.
- **oil** (`-` or `<Space>e`) — opens a directory as an editable buffer.
  Rename by editing a line, `dd` to delete, type a line to create, `:w` to
  apply. Far better for *changing* structure, especially bulk renames.

## What's in `lua/custom/plugins/`

| File | What |
|---|---|
| `files.lua` | oil.nvim — edit the filesystem as a buffer |
| `git.lua` | fugitive, diffview, and a lazygit floating window |
| `claude.lua` | claudecode.nvim bridge and its keymaps |
| `markdown.lua` | render-markdown.nvim — styled in-buffer markdown |
| `legacy-vimrc.lua` | settings and keymaps ported from the old vimrc |

## Cheatsheet (leader = Space)

Press Space and pause; which-key shows everything. `<Space>sk` fuzzy-searches
all keymaps.

| Keys | What |
|---|---|
| `<C-p>` | fuzzy find files (the old CtrlP binding) |
| `<Space>b` | buffers (old `<Leader>b`) |
| `<Space>sf` / `<Space>sg` | find files / live grep (Telescope) |
| `<Space><Space>` | open buffers |
| `\` | sidebar file tree (neo-tree); `\` again closes it |
| `-` | file explorer (oil): edit dirs like text, `:w` applies |
| `<Space>e` | oil, from the old `<Leader>e` |
| `<Space>v` / `<Space>-` | vertical / horizontal split |
| `grd` / `grr` / `grn` | LSP: definition / references / rename |
| `<Space>f` | format buffer |
| `<Space>ac` | toggle Claude Code split |
| visual + `<Space>as` | send selection to Claude as context |
| `<Space>aa` / `<Space>ad` | accept / reject Claude's proposed diff |
| `]c` / `[c` | next / prev changed hunk (review agent edits) |
| `<Space>hp` / `<Space>hr` | preview / revert hunk |
| `<Space>gd` | side-by-side review of the whole working-tree diff |
| `<Space>gg` | lazygit floating window |
| `<Space>tb` / `<Space>tw` / `<Space>th` | toggle blame line / word diff / inlay hints |
| `<Space>tm` | toggle in-buffer markdown rendering |

**Bridge tip:** a Claude Code session already running in a separate terminal
can attach to Neovim by typing `/ide` inside Claude Code. Run both from the
same project directory.

## Notes

- Buffers auto-reload when changed on disk (Section 2). This is the single
  most important setting for agent workflows — without it, buffers go stale
  the moment Claude edits a file you have open.
- The old pathogen-era Vim config lives on the `master` branch of this repo,
  kept for reference. It is not used.
