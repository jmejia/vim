-- [[ oil.nvim ]] Edit the filesystem like a normal buffer.
-- The modern replacement for netrw/NERDTree: press `-` to open the parent
-- directory, edit filenames like text, `:w` to apply renames/moves/deletes.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'stevearc/oil.nvim' }

require('oil').setup {
  view_options = { show_hidden = true },
  -- Keep netrw disabled; oil takes over directory buffers
  default_file_explorer = true,
}

vim.keymap.set('n', '-', '<cmd>Oil<CR>', { desc = 'Open parent directory (oil)' })
