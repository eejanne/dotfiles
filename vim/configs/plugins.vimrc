" Load plugins
call plug#begin('$HOME/.config/nvim/plugged')
Plug 'neovim/nvim-lspconfig'

Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'williamboman/nvim-lsp-installer'

Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

Plug 'tpope/vim-fugitive'
Plug 'sindrets/diffview.nvim'
Plug 'nvim-tree/nvim-web-devicons'

Plug 'neanias/everforest-nvim', { 'branch': 'main' }
Plug 'tpope/vim-sleuth'
Plug 'Raimondi/delimitMate'
Plug 'mfussenegger/nvim-lint'
Plug 'nvim-lualine/lualine.nvim'
Plug 'sheerun/vim-polyglot/'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'mileszs/ack.vim'
Plug 'lukas-reineke/indent-blankline.nvim'

Plug 'github/copilot.vim'
Plug 'nvim-lua/plenary.nvim'
Plug 'NickvanDyke/opencode.nvim'
Plug 'folke/snacks.nvim'
Plug 'christoomey/vim-tmux-navigator'
call plug#end()


let g:python3_host_prog = expand('~/nvim-env/bin/python3')

" LSP configuration
set completeopt=menu,menuone,noselect

" The line below is not official
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']

lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require('cmp')

  -- Utils
  local check_backspace = function()
    local col = vim.fn.col "." - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
  end
  ----------------

  require("nvim-lsp-installer").setup {}

  -- Load snippets
  require("luasnip.loaders.from_vscode").lazy_load()

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      end,
    },
    window = {
      -- completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<Tab>"] = cmp.mapping(function(fallback)
        local luasnip = require "luasnip"
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif check_backspace() then
          fallback()
        else
          fallback()
        end
	  end, {"i", "s"}),
	  ["<S-Tab>"] = cmp.mapping(function(fallback)
        local luasnip = require "luasnip"
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.expandable() then
          luasnip.expand()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif check_backspace() then
          fallback()
        else
          fallback()
        end
	  end, {"i", "s"}),
    }),
    snippet = {
      expand = function(args)
        local luasnip = prequire("luasnip")
        if not luasnip then
          return
        end
        luasnip.lsp_expand(args.body)
      end,
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
    }),
  })

  -- Set configuration for specific filetype.
  cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
      { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  -- cmp.setup.cmdline(':', {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = cmp.config.sources({
  --     { name = 'path' }
  --   }, {
  --     { name = 'cmdline' }
  --   })
  -- })

  -- Setup lspconfig.
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
  -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
  local servers = {'bashls', 'eslint', 'tsserver', 'cssmodules_ls', 'tailwindcss', 'pyright'}
  for _, server in pairs(servers) do
    require('lspconfig')[server].setup {
      capabilities = capabilities,
      root_dir = require('lspconfig.util').root_pattern('.git')(fname)
    }
    -- require('lspconfig')[server].setup{
    --  root_dir = util.root_pattern('.git')(fname)
    -- }
  end
  -- Use å/Å to jump to the next or previous diagnostic errors
  vim.keymap.set('n', 'Å', vim.diagnostic.goto_prev)
  vim.keymap.set('n', 'å', vim.diagnostic.goto_next)

  -- Setup indentation indicator lines
  require("ibl").setup()
EOF

" Set color settings to accomodate Oceanic-Next
if (has("termguicolors"))
 set termguicolors
endif

set background=light

lua <<EOF
require('everforest').setup({
  ---Controls the "hardness" of the background. Options are "soft", "medium" or "hard".
  background = "medium"
})
EOF

" For better performance
let g:everforest_better_performance = 1
syntax enable
colorscheme everforest

" Have statusline always be visible
set laststatus=2


"""""""""""""""""""""""""""""""""""""""
" Linting
"""""""""""""""""""""""""""""""""""""""

lua <<EOF
require('lint').linters_by_ft = {
  markdown = {'vale',},
  python = {'flake8',},
  javascript = { "eslint", "tsserver"},
  typescriptreact = { "eslint", "tsserver" },
  typescript = { "eslint", "tsserver" },
}
EOF


lua <<EOF
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'everforest'
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {
      {
        'diagnostics',
        symbols = {error = '✕', warn = '⚠ ', info = 'I', hint = 'H'},
        colored = true,           -- Displays diagnostics status in color if set to true.
        update_in_insert = false, -- Update diagnostics in insert mode.
        always_visible = false   -- Show diagnostics even if there are none.
      }
    },
    lualine_c = {
      {
        'filename',
        symbols = {modified = '•'}
      }
    },
    lualine_x = {'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  winbar = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,
        symbols = {modified = '•'}
      }
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  inactive_winbar = {  -- ensure the top bar/winbar is always shown
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        path = 1,
        symbols = {modified = '•'}
      }
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  }
}
EOF

" Set maximum line length to 120 for black python fixer
let g:black_linelength=120


"""""""""""""""""""""""""""""""""""""""
" Copilot code completion
"""""""""""""""""""""""""""""""""""""""

lua <<EOF
vim.keymap.set('i', '<C-q>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

vim.g.copilot_settings = { selectedCompletionModel = 'gpt-41-copilot' }

vim.keymap.set('i', '<C-a>', '<Plug>(copilot-suggest)')
EOF

"""""""""""""""""""""""""""""""""""""""
" Opencode.nvim
"""""""""""""""""""""""""""""""""""""""
lua <<EOF
vim.g.opencode_opts = {
  port = nil, -- Let opencode.nvim auto-discover running instances in the current directory
  provider = {
    enabled = "tmux", -- Use tmux provider to run in separate pane
    tmux = {
      options = "-h -d", -- Open in horizontal split, detached
    },
  },
  theme = "everforest",
  events = {
    enabled = true,
  },
}

-- Required for `opts.events.reload`.
vim.o.autoread = true

-- Custom toggle function that hides/shows tmux pane instead of killing it
local opencode_pane_id = nil

local function pane_exists(pane_id)
  if not pane_id or pane_id == "" then return false end
  local result = vim.fn.system(string.format("tmux list-panes -a -F '#{pane_id}' | grep -q '%s' && echo 'yes' || echo 'no'", pane_id))
  return vim.trim(result) == "yes"
end

local function is_pane_in_current_window(pane_id)
  if not pane_id or pane_id == "" then return false end
  local result = vim.fn.system("tmux list-panes -F '#{pane_id}'")
  return result:find(vim.trim(pane_id), 1, true) ~= nil
end

local function toggle_opencode_visibility()
  local provider = require("opencode.config").provider

  -- Update our stored pane_id if provider has one
  if provider and provider.pane_id and provider.pane_id ~= "" then
    opencode_pane_id = vim.trim(provider.pane_id)
  end

  -- If we have a pane and it's in current window (visible), hide it
  if opencode_pane_id and pane_exists(opencode_pane_id) and is_pane_in_current_window(opencode_pane_id) then
    -- Break the pane into a new window to hide it
    vim.fn.system(string.format("tmux break-pane -d -s %s", opencode_pane_id))
  -- If we have a pane but it's not in current window (hidden), show it
  elseif opencode_pane_id and pane_exists(opencode_pane_id) then
    -- Re-join the hidden pane
    vim.fn.system(string.format("tmux join-pane -h -s %s", opencode_pane_id))
    -- Move cursor to the opencode pane
    vim.fn.system(string.format("tmux select-pane -t %s", opencode_pane_id))
  -- No pane exists, start opencode
  else
    require("opencode").start()
    -- Give it a moment to start, then select the pane
    vim.defer_fn(function()
      if provider and provider.pane_id and provider.pane_id ~= "" then
        opencode_pane_id = vim.trim(provider.pane_id)
        vim.fn.system(string.format("tmux select-pane -t %s", provider.pane_id))
      end
    end, 500)
  end
end

-- Recommended/example keymaps.
vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
vim.keymap.set({ "n", "t" }, "<C-q>", toggle_opencode_visibility,                                           { desc = "Toggle opencode visibility" })

vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

-- Vim-style page up/down navigation for opencode
vim.keymap.set("n", "<leader>b", function() require("opencode").command("session.page.up") end,   { desc = "Scroll opencode up (full page)" })
vim.keymap.set("n", "<leader>j", function() require("opencode").command("session.page.down") end, { desc = "Scroll opencode down (full page)" })

-- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
-- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
-- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })

EOF


""""""""""""""""""""""""""""""""""""
" Ag + Fzf
""""""""""""""""""""""""""""""""""""
" Use Ag as search backend if available
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Make sure fuzzyfinding ignores the files in the gitignore
" but doesn't ignore the gitignore itself.
let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore ".git" -g ""'

" Freeform text search
nnoremap <Leader>c :Ag<CR>

" Search file names
nnoremap <Leader>f :Files<CR>

" Search among open buffers
nnoremap <Leader>r :Buffers<CR>

" Place the fuzzyfinder window at the bottom of the vim screen
let g:fzf_layout = { 'down':  '40%'}

" Customize fzf colors to match color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }


""""""""""""""""""""""""""""""""""""
" Fugitive
""""""""""""""""""""""""""""""""""""
" Force side-by-side diffs no matter the width of the vim window
set diffopt=vertical

" Override Gdiff to use DiffviewOpen instead
command! -nargs=? Gdiff :DiffviewOpen <args>
command! -nargs=? GdiffThis :DiffviewFileHistory %


""""""""""""""""""""""""""""""""""""
" Diffview
""""""""""""""""""""""""""""""""""""
lua <<EOF
local actions = require("diffview.actions")

require("diffview").setup({
  enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = true,
    },
    merge_tool = {
      layout = "diff3_horizontal",
      disable_diagnostics = true,
      winbar_info = true,
    },
    file_history = {
      layout = "diff2_horizontal",
      winbar_info = true,
    },
  },
  keymaps = {
    view = {
      -- Mappings in diff views
      { "n", "<tab>",      actions.select_next_entry,              { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>",    actions.select_prev_entry,              { desc = "Open the diff for the previous file" } },
      { "n", "[x",         actions.prev_conflict,                  { desc = "Jump to previous conflict" } },
      { "n", "]x",         actions.next_conflict,                  { desc = "Jump to next conflict" } },
      { "n", "<leader>co", actions.conflict_choose("ours"),        { desc = "Choose the OURS version of a conflict" } },
      { "n", "<leader>ct", actions.conflict_choose("theirs"),      { desc = "Choose the THEIRS version of a conflict" } },
      { "n", "<leader>cb", actions.conflict_choose("base"),        { desc = "Choose the BASE version of a conflict" } },
      { "n", "<leader>ca", actions.conflict_choose("all"),         { desc = "Choose all the versions of a conflict" } },
      { "n", "dx",         actions.conflict_choose("none"),        { desc = "Delete the conflict region" } },
      { "n", "<leader>h",  "<C-w>h",                               { desc = "Move to left panel" } },
      { "n", "<leader>l",  "<C-w>l",                               { desc = "Move to right panel" } },
    },
    file_panel = {
      -- Mappings in file panel
      { "n", "j",             actions.next_entry,                     { desc = "Bring cursor to next file entry" } },
      { "n", "<down>",        actions.next_entry,                     { desc = "Bring cursor to next file entry" } },
      { "n", "k",             actions.prev_entry,                     { desc = "Bring cursor to previous file entry" } },
      { "n", "<up>",          actions.prev_entry,                     { desc = "Bring cursor to previous file entry" } },
      { "n", "<cr>",          actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
      { "n", "<tab>",         actions.select_next_entry,              { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>",       actions.select_prev_entry,              { desc = "Open the diff for the previous file" } },
      { "n", "[x",            actions.prev_conflict,                  { desc = "Jump to previous conflict" } },
      { "n", "]x",            actions.next_conflict,                  { desc = "Jump to next conflict" } },
      { "n", "<leader>gf",    actions.goto_file_edit,                 { desc = "Open file in new split" } },
      { "n", "<leader>h",     "<C-w>h",                               { desc = "Move to left panel" } },
      { "n", "<leader>l",     "<C-w>l",                               { desc = "Move to right panel" } },
      { "n", "s",             actions.toggle_stage_entry,             { desc = "Stage/unstage the selected entry" } },
      { "n", "S",             actions.stage_all,                      { desc = "Stage all entries" } },
      { "n", "U",             actions.unstage_all,                    { desc = "Unstage all entries" } },
      { "n", "X",             actions.restore_entry,                  { desc = "Restore entry to the state on the left side" } },
      { "n", "R",             actions.refresh_files,                  { desc = "Update stats and entries in the file list" } },
    },
    file_history_panel = {
      { "n", "g!",            actions.options,                        { desc = "Open the option panel" } },
      { "n", "<C-A-d>",       actions.open_in_diffview,               { desc = "Open commit in diffview" } },
      { "n", "y",             actions.copy_hash,                      { desc = "Copy the commit hash" } },
      { "n", "L",             actions.open_commit_log,                { desc = "Show commit details" } },
      { "n", "zR",            actions.open_all_folds,                 { desc = "Expand all folds" } },
      { "n", "zM",            actions.close_all_folds,                { desc = "Collapse all folds" } },
      { "n", "j",             actions.next_entry,                     { desc = "Bring cursor to next file entry" } },
      { "n", "<down>",        actions.next_entry,                     { desc = "Bring cursor to next file entry" } },
      { "n", "k",             actions.prev_entry,                     { desc = "Bring cursor to previous file entry" } },
      { "n", "<up>",          actions.prev_entry,                     { desc = "Bring cursor to previous file entry" } },
      { "n", "<cr>",          actions.select_entry,                   { desc = "Open the diff for the selected entry" } },
      { "n", "<tab>",         actions.select_next_entry,              { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>",       actions.select_prev_entry,              { desc = "Open the diff for the previous file" } },
    },
  },
})

-- Track the last modified diff buffer for global undo
vim.g.diff_last_modified_buf = nil

-- Visual mode diffput: pushes changes TO the other buffer (other buffer is modified)
vim.keymap.set('x', 'dp', function()
  local win_ids = vim.api.nvim_tabpage_list_wins(0)
  for _, win_id in ipairs(win_ids) do
    if win_id ~= vim.api.nvim_get_current_win() then
      local buf = vim.api.nvim_win_get_buf(win_id)
      if vim.api.nvim_get_option_value('diff', { win = win_id }) then
        vim.g.diff_last_modified_buf = buf
        break
      end
    end
  end
  return ':diffput<CR>'
end, { expr = true, desc = 'Diff put selected lines' })

-- Visual mode diffget: pulls changes FROM the other buffer (current buffer is modified)
vim.keymap.set('x', 'do', function()
  vim.g.diff_last_modified_buf = vim.api.nvim_get_current_buf()
  return ':diffget<CR>'
end, { expr = true, desc = 'Diff get selected lines' })

-- Smart undo: in diff mode or diffview file panel, undo in last modified buffer; otherwise normal undo
vim.keymap.set('n', 'u', function()
  local in_diff = vim.api.nvim_get_option_value('diff', { win = 0 })
  local filetype = vim.api.nvim_get_option_value('filetype', { buf = 0 })
  local in_diffview_panel = filetype == 'DiffviewFiles' or filetype == 'DiffviewFileHistory'
  local buf = vim.g.diff_last_modified_buf
  
  if (in_diff or in_diffview_panel) and buf and vim.api.nvim_buf_is_valid(buf) then
    -- Find window containing the buffer and undo there
    local win_ids = vim.api.nvim_tabpage_list_wins(0)
    for _, win_id in ipairs(win_ids) do
      if vim.api.nvim_win_get_buf(win_id) == buf then
        local current_win = vim.api.nvim_get_current_win()
        vim.api.nvim_set_current_win(win_id)
        vim.cmd('undo')
        vim.api.nvim_set_current_win(current_win)
        return
      end
    end
    -- Buffer exists but not visible in current tab, undo anyway
    vim.api.nvim_buf_call(buf, function() vim.cmd('undo') end)
  else
    -- Normal undo
    vim.cmd('undo')
  end
end, { desc = 'Smart undo (diff-aware)' })
EOF

" Diffview keymaps
nnoremap <leader>dv :lua if next(require('diffview.lib').views) == nil then vim.cmd('DiffviewOpen') else vim.cmd('DiffviewClose') end<CR>
nnoremap <leader>dh :DiffviewFileHistory<CR>
nnoremap <leader>df :DiffviewFileHistory %<CR>
