-- [[ claudecode.nvim ]] The Claude Code <-> Neovim bridge.
--
-- Speaks the same WebSocket protocol as Anthropic's official VS Code/JetBrains
-- extensions, so Claude Code treats Neovim as its IDE:
--   * Claude sees which file/selection you have open (context flows out)
--   * Claude's proposed edits open as native diffs here (review flows in)
--
-- Works two ways:
--   1. <leader>ac opens Claude in a split inside Neovim, or
--   2. run `claude` in any terminal inside this Neovim instance and it
--      auto-connects to the same session.
--
-- In the diff view: <leader>aa accepts, <leader>ad rejects.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'coder/claudecode.nvim' }

require('claudecode').setup {
  -- Use Neovim's native terminal (no snacks.nvim dependency)
  terminal = {
    provider = 'native',
    split_side = 'right',
    split_width_percentage = 0.35,
  },
}

local map = vim.keymap.set
map('n', '<leader>ac', '<cmd>ClaudeCode<CR>', { desc = 'Claude: toggle terminal' })
map('n', '<leader>af', '<cmd>ClaudeCodeFocus<CR>', { desc = 'Claude: focus/toggle window' })
map('n', '<leader>ar', '<cmd>ClaudeCode --resume<CR>', { desc = 'Claude: resume prior session' })
map('n', '<leader>aC', '<cmd>ClaudeCode --continue<CR>', { desc = 'Claude: continue last session' })
map('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<CR>', { desc = 'Claude: add current buffer as context' })
map('v', '<leader>as', '<cmd>ClaudeCodeSend<CR>', { desc = 'Claude: send selection as context' })
map('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<CR>', { desc = 'Claude: accept proposed diff' })
map('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<CR>', { desc = 'Claude: reject proposed diff' })
