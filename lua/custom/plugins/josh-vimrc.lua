-- [[ Ported from the old vimrc ]]
-- Source: github.com/jmejia/vim/blob/master/vimrc.vim
--
-- The settings worth keeping, modernized. Kept in this file rather than in
-- init.lua so the kickstart base stays close to upstream and future merges
-- on the `josh` branch stay clean. This loads last (via `require
-- 'custom.plugins'` in Section 10), so anything here wins over kickstart.
--
-- Deliberately NOT ported:
--   pathogen#infect()       -> vim.pack (Section 3)
--   CtrlP + GoodMatch()     -> Telescope. The old matcher hardcoded
--                              /usr/local/bin/matcher, an Intel-Homebrew path
--                              that doesn't exist on this arm64 machine.
--   Ag / g:ackprg           -> Telescope live_grep over ripgrep (<leader>sg)
--   guifont / guioptions    -> terminal-only now; Ghostty owns the font
--   filetype plugin indent  -> Neovim default
--   set number              -> already set in Section 1
--   :map <Space> <PageDown> -> Space is the leader key. which-key runs at
--                              delay = 0, so a bare-Space motion fights the
--                              hint popup on every press. Use <C-d>/<C-f>.

-- ============================================================
-- Options
-- ============================================================

vim.o.swapfile = false -- old: set noswapfile
vim.o.wrap = false -- old: set nowrap (Neovim defaults wrap ON, so this matters)

-- Indentation: 4 spaces by default, which is also what PEP 8 wants for the
-- Python work.
vim.o.expandtab = true -- old: set expandtab
vim.o.autoindent = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- ...except in languages that conventionally use 2. The old vimrc listed
-- ruby/eruby/yaml; lua, json and markdown are added here because this config
-- is itself Lua and the project carries a lot of markdown. Trim freely.
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Two-space indentation for languages that expect it',
  group = vim.api.nvim_create_augroup('josh-indent', { clear = true }),
  pattern = { 'ruby', 'eruby', 'yaml', 'lua', 'json', 'jsonc', 'markdown' },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.softtabstop = 2
    vim.bo.expandtab = true
  end,
})

-- Section 1 already sets list + listchars (tab/trail/nbsp). The old config
-- also flagged lines running off-screen, so add just that one.
vim.opt.listchars:append { extends = '#' }

-- ============================================================
-- Keymaps
-- ============================================================

local map = vim.keymap.set

-- [[ Fuzzy find ]] <C-p> is the key CtrlP actually bound; the old `<leader>t`
-- was just an alias for it. Free to take: its normal-mode built-in is a legacy
-- synonym for `k`. Insert-mode <C-p> is deliberately untouched -- blink.cmp
-- uses it to walk the completion menu.
map('n', '<C-p>', function() require('telescope.builtin').find_files() end, { desc = 'Find files (fuzzy)' })

-- old: <Leader>b -> :CtrlPBuffer. Free because kickstart only binds <leader>b
-- inside kickstart.plugins.debug, which is not enabled.
map('n', '<leader>b', function() require('telescope.builtin').buffers() end, { desc = '[B]uffers' })

-- [[ Splits ]] <leader>v is unchanged from the old vimrc. <leader>s is NOT
-- reused for :split -- it prefixes kickstart's 12-mapping [S]earch group.
-- <leader>- reads like a horizontal divider and was unbound.
map('n', '<leader>v', '<cmd>vsplit<CR>', { desc = 'Split [V]ertical' })
map('n', '<leader>-', '<cmd>split<CR>', { desc = 'Split horizontal' })

-- [[ File explorer ]] old: <Leader>e -> :Explore (netrw). oil replaces netrw;
-- `-` (in files.lua) is oil's idiomatic "up one directory".
map('n', '<leader>e', '<cmd>Oil<CR>', { desc = '[E]xplore (oil)' })

-- [[ Misc ]] make C-c act like Esc, for things like :normal I
map('i', '<C-c>', '<Esc>', { desc = 'Escape' })
