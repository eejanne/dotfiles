" To enable saving with Ctrl-s
nmap <C-s> :w<CR>
imap <C-s> <Esc>:w<CR>a

" Shortcuts for moving between tabs with Ctrl-Shift-h/l
" (Ctrl-h/l are now handled by vim-tmux-navigator for split/pane navigation)
" This is done specifically to allow for navigating vim splits in the same way
" as tmux panes.
nmap <C-S-h> gT
nmap <C-S-l> gt

" Commands for moving and deleting to end/beginning of line optimized for swe-keyboard
noremap - $
noremap , ^

" Map x to a delete without yanking
nmap x "_d
vmap x "_d
nmap xx "_dd

" To make copy-pasting (and toggling the paste-mode) easier
nnoremap <F2> :set invpaste paste?<CR>

" Replace currently selected text with default register
" without yanking it. In other words, 'paste-in-place'
vnoremap p "_dP

" Unset space to allow the leader key to be set to space
nnoremap <SPACE> <Nop>
" Set leader key
let mapleader = " "
