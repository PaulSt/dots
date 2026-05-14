" =============================================================================
" Core
" =============================================================================
set nocompatible

" Leader keys
nnoremap <Space> <Nop>
let mapleader = ' '
let maplocalleader = ' '

" Encoding
set encoding=utf-8
set fileencoding=utf-8
set fileformats=unix,dos,mac

" =============================================================================
" vim-plug bootstrap
" =============================================================================
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" =============================================================================
" Plugins
" =============================================================================
call plug#begin('~/.vim/plugged')

" Theme
Plug 'morhetz/gruvbox'

" Start screen
Plug 'mhinz/vim-startify'

" Comments: <leader>cc, <leader>cu, ...
Plug 'preservim/nerdcommenter'

" Motions
Plug 'justinmk/vim-sneak'

" LaTeX
Plug 'lervag/vimtex'

" Markdown / Obsidian notes in plain Vim
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }

" Zen mode
Plug 'junegunn/goyo.vim'

" Marks
Plug 'kshenoy/vim-signature'

" GitHub Copilot
Plug 'github/copilot.vim'

" Undo tree
Plug 'mbbill/undotree'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Neovim-only plugins. Keep these guarded so the same file is safe in Vim.
if has('nvim')
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
  Plug 'teamtype/teamtype-nvim'

  " If you want deep Obsidian integration in Neovim, enable this and configure
  " your vault path in the Lua block below.
  " Plug 'obsidian-nvim/obsidian.nvim'
endif

call plug#end()

" Install missing plugins automatically, after g:plugs has been populated.
augroup install_missing_plugins
  autocmd!
  autocmd VimEnter * if exists('g:plugs') && len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) | PlugInstall --sync | source $MYVIMRC | endif
augroup END

filetype plugin indent on
syntax on

" =============================================================================
" Plugin configuration
" =============================================================================

" vimtex
let g:vimtex_view_method = 'zathura'
let g:vimtex_indent_enabled = 0

function! s:tex_build_dir(file_info) abort
  let l:name = get(a:file_info, 'jobname', '')
  if empty(l:name)
    let l:name = fnamemodify(get(a:file_info, 'target_basename', 'main.tex'), ':r')
  endif
  return 'buildtex/' . l:name
endfunction

let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_compiler_latexmk = {
      \ 'out_dir' : function('s:tex_build_dir'),
      \ 'aux_dir' : function('s:tex_build_dir'),
      \ 'options' : [
      \   '-pdf',
      \   '-file-line-error',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \   '--shell-escape',
      \ ],
      \ }

" vim-markdown: Obsidian-friendly Markdown editing without taking over too much.
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_new_list_item_indent = 2

" markdown-preview.nvim
let g:mkdp_auto_start = 0
let g:mkdp_auto_close = 1
let g:mkdp_filetypes = ['markdown']

" airline
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" Optional Neovim Obsidian setup. Uncomment the Plug line above and this block,
" then replace the path with your vault path.
" if has('nvim')
" lua << EOF
" require('obsidian').setup({
"   workspaces = {
"     { name = 'main', path = '~/Documents/Obsidian' },
"   },
" })
" EOF
" endif

" =============================================================================
" Theme and UI
" =============================================================================
set background=dark
set termguicolors
set t_Co=256

function! s:GruvboxOverrides() abort
  " Search highlight used by * and /
  "highlight Search    ctermfg=235 ctermbg=214 guifg=#282828 guibg=#fabd2f
  highlight IncSearch ctermfg=235 ctermbg=208 guifg=#282828 guibg=#fe8019
  silent! highlight CurSearch ctermfg=235 ctermbg=167 guifg=#282828 guibg=#fb4934

  " Comments
  highlight Comment ctermfg=245 guifg=#928374 gui=italic cterm=italic
  highlight! link @comment Comment
  highlight! link @comment.documentation Comment
endfunction

augroup gruvbox_overrides
  autocmd!
  autocmd ColorScheme gruvbox call s:GruvboxOverrides()
augroup END

silent! colorscheme gruvbox
call s:GruvboxOverrides()

set number relativenumber
set scrolloff=7
set showmatch
set matchtime=2
set wildmenu
set path+=**
set lazyredraw

" Search
set ignorecase
set smartcase
set hlsearch
set incsearch

" Mouse and clipboard
set mouse=a
set clipboard=unnamedplus

" Buffers, backup, undo
set autoread
set hidden
set nobackup
set nowritebackup
set noswapfile

if has('persistent_undo')
  let s:undo_dir = expand('~/.config/vim-persisted-undo')
  if !isdirectory(s:undo_dir)
    call mkdir(s:undo_dir, 'p')
  endif
  let &undodir = s:undo_dir
  set undofile
endif

" =============================================================================
" netrw
" =============================================================================
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 0
let g:netrw_winsize = 15

" =============================================================================
" Editing, tabs, indentation
" =============================================================================
set expandtab
set smarttab
set shiftwidth=4
set tabstop=4
set linebreak
set textwidth=500
set wrap
set autoindent
set smartindent
" search for files in the directory of the current file, not the cwd of Vim.
set autochdir

" LaTeX: no automatic indentation.
augroup latex_no_autoindent
  autocmd!
  autocmd FileType tex,latex,plaintex setlocal noautoindent nosmartindent nocindent indentexpr=
augroup END

" Markdown / Obsidian notes: prose-friendly local settings.
augroup markdown_notes
  autocmd!
  autocmd FileType markdown setlocal wrap linebreak textwidth=0 conceallevel=2
augroup END

" clang-format only for C/C++-like files.
augroup clang_format_equalprg
  autocmd!
  autocmd FileType c,cpp,objc,objcpp setlocal equalprg=clang-format
augroup END

" Remove trailing whitespace on save for selected filetypes.
function! s:StripTrailingWhitespace() abort
  let l:view = winsaveview()
  keeppatterns keepjumps %s/\s\+$//e
  call winrestview(l:view)
endfunction

augroup strip_trailing_whitespace
  autocmd!
  autocmd FileType sh,perl,python,c,cpp autocmd BufWritePre <buffer> call s:StripTrailingWhitespace()
augroup END

" =============================================================================
" Mappings
" =============================================================================

" Buffer navigation
nnoremap <silent> <C-h> :bprevious<CR>
nnoremap <silent> <C-l> :bnext<CR>

" Toggle relative numbers
nnoremap <silent> <C-n><C-n> :setlocal invrelativenumber<CR>

" Telescope only exists in Neovim.
if has('nvim')
  nnoremap <silent> <C-p> <cmd>Telescope find_files<CR>
  " nnoremap <silent> <leader>ff <cmd>Telescope find_files<CR>
  " nnoremap <silent> <leader>fg <cmd>Telescope live_grep<CR>
  " nnoremap <silent> <leader>fb <cmd>Telescope buffers<CR>
endif

" Goyo
nnoremap <silent> <C-g><C-g> :Goyo<CR>

" Undotree
nnoremap <silent> U :UndotreeToggle<CR>

" Window switching
nnoremap <silent> <Tab> <C-w>w

" German keyboard search convenience
nnoremap - /

" Faster line motion / paging. This intentionally replaces default H/L/J/K.
noremap L $
noremap H ^
noremap J <C-d>
noremap K <C-u>
noremap <Down> <C-d>
noremap <Up> <C-u>
noremap <C-j> J

" Go to mark using M instead of '
noremap M '

" jk / kj escape
inoremap jk <Esc>
inoremap kj <Esc>

" Sudo write
command! W w !sudo tee % > /dev/null

" Tags
set tags=tags;~
