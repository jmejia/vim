-- [[ render-markdown.nvim ]] Pretty markdown, rendered in the buffer.
-- Styled headings, bullets, checkboxes, tables, and code blocks via
-- treesitter conceal. The cursor line reveals raw markdown so editing
-- stays natural. Handy for reading plans/docs that Claude writes.
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }

require('render-markdown').setup {
  completions = { blink = { enabled = true } }, -- checkbox/callout completions
}

vim.keymap.set('n', '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', { desc = '[T]oggle [M]arkdown rendering' })
