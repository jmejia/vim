-- [[ Git tooling for reviewing changes, especially agent-made changesets ]]
--
-- Layers (smallest to largest scope):
--   gitsigns  - per-hunk: ]c / [c to jump, <leader>h* to stage/reset/preview
--               (configured in kickstart.plugins.gitsigns)
--   fugitive  - classic :G blame, :Gdiffsplit, :G log
--   diffview  - whole-changeset review: everything Claude just touched,
--               side-by-side, one file at a time
--   lazygit   - full TUI for staging/committing, in a floating terminal
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add {
  gh 'tpope/vim-fugitive',
  gh 'sindrets/diffview.nvim',
}

require('diffview').setup {}

vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff working tree (review changeset)' })
vim.keymap.set('n', '<leader>gq', '<cmd>DiffviewClose<CR>', { desc = '[G]it diff close' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it file [H]istory' })
vim.keymap.set('n', '<leader>gb', '<cmd>G blame<CR>', { desc = '[G]it [B]lame (fugitive)' })

-- lazygit in a floating terminal (no plugin needed)
vim.keymap.set('n', '<leader>gg', function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.9)
  local height = math.floor(vim.o.lines * 0.9)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded',
  })
  vim.fn.jobstart({ 'lazygit' }, {
    term = true,
    on_exit = function() vim.api.nvim_buf_delete(buf, { force = true }) end,
  })
  vim.cmd 'startinsert'
end, { desc = '[G]it lazy[G]it' })
