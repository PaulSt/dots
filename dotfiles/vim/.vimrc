" set leader (has to be before any leader command is defined)
nnoremap <space> <Nop>
let mapleader = " "
let maplocalleader = "+"
" Necesary for lots of cool vim things
set nocompatible

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Install vim-plug
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

" Automatically install missing plugins on startup
if !empty(filter(copy(g:plugs), '!isdirectory(v:val.dir)'))
    autocmd VimEnter * PlugInstall | q
endif

" colorscheme
Plug 'morhetz/gruvbox'

" tags
"Plug 'craigemery/vim-autotag'
Plug 'ludovicchabant/vim-gutentags'

" startscreen
Plug 'mhinz/vim-startify'

" autocompletion
Plug 'ajh17/VimCompletesMe'

" comments with <leader> cc
Plug 'scrooloose/nerdcommenter'

" ctrlp fuzzy file, buffer,.. finder
Plug 'ctrlpvim/ctrlp.vim'

" missing notion of vim
Plug 'justinmk/vim-sneak'

" latex
Plug 'lervag/vimtex'

" snippets
Plug 'KeyboardFire/vim-minisnip'
let g:minisnip_trigger = '<C-k>'

" org-mode
Plug 'jceb/Vim-OrgMode'
Plug 'tpope/vim-speeddating'

" buffers in tabline
Plug 'ap/vim-buftabline'
nnoremap <C-h> :bprev<CR>
nnoremap <C-l> :bnext<CR>

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Looks
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" scheme
set background=dark
colorscheme gruvbox
set t_Co=256                "colors in terminal
syntax enable               "syntax highlighting

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Basics
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf8

" Set to auto read when a file is changed from the outside
set autoread

" A buffer becomes hidden when it is abandoned
set hidden

" Turn backup off
set nobackup
set nowritebackup
set noswapfile

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Hide mouse when typing
set mousehide

" highlight entire line of curser
set cursorline
" Default Colors for CursorLine
highlight  CursorLine cterm=underline ctermfg=none ctermbg=none
" Change Color when entering Insert Mode
autocmd InsertEnter * highlight CursorLine cterm=underline ctermfg=none ctermbg=none
" Revert Color to default when leaving Insert Mode
autocmd InsertLeave * highlight CursorLine cterm=underline ctermfg=none ctermbg=none

" linenumbers
set number relativenumber
nmap <C-N><C-N> :set invrelativenumber<CR>

" copy to clipboard
 set clipboard=unnamedplus

" Set 7 lines to the cursor - when moving vertically using j/k
set scrolloff=7

" search into subfolders when using :find
set path+=**

" Turn on the Wild menu
set wildmenu
" set wildmode=list:longest,full

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching
set ignorecase

" When searching try to be smart about cases 
set smartcase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch 

" Don't redraw while executing macros (good performance config)
set lazyredraw 

" For regular expressions turn magic on
" set magic

" Show matching brackets when text indicator is over them
set showmatch 

" How many tenths of a second to blink when matching brackets
set mat=2

" tab change window and set root to buffer location
set autochdir
map <Tab> <C-W>W:cd %:p:h<CR>:<CR>

" search for tag file
set tags=tags;~

" allows for filetype detection
filetype plugin on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => netrw (filer) settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 0
let g:netrw_winsize = 15
"augroup ProjectDrawer
"    autocmd!
"    autocmd VimEnter * :Lexplore!
"augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => nifty custom mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" $ is  a pain. use L instead. i never use L anyways..
noremap L $
noremap H ^

" ctrl+d, ctrl+u is unintuitive
noremap J <C-d>
noremap K <C-u>
" save J
noremap <c-j> J

" press j and k at the same time to get escape
inoremap jk <esc>
inoremap kj <esc>

" :W sudo saves the file 
" (useful for handling the permission-denied error)
command! W w !sudo tee % > /dev/null

" map / to - for faster search on german keyboard
noremap - /

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs
set expandtab

" Be smart when using tabs ;)
set smarttab

" 1 tab == 4 spaces
set shiftwidth=4
set tabstop=4

" Linebreak on 500 characters
set linebreak
set textwidth=500

set autoindent 
set smartindent

" wrap lines
set wrap 

" special behaviour in tex files
let g:tex_indent_brace = 0

" Don't indent namespace and template
function! CppNoNamespaceAndTemplateIndent()
    let l:cline_num = line('.')
    let l:cline = getline(l:cline_num)
    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
        let l:pline_num = prevnonblank(l:pline_num - 1)
        let l:pline = getline(l:pline_num)
    endwhile
    let l:retv = cindent('.')
    let l:pindent = indent(l:pline_num)
    if l:pline =~# '^\s*template<.*$'
        let l:retv = l:pindent
    elseif l:pline =~# '^.*::\s*$'
        let l:retv = l:pindent
    elseif l:pline =~# '^\s*HD NGS_DLL_HEADER$'
        let l:retv = l:pindent
        "elseif l:pline =~# '\s*typename\s*.*,\s*$'
        "    let l:retv = l:pindent
        "elseif l:cline =~# '^\s*>\s*$'
        "    let l:retv = l:pindent - &shiftwidth
        "elseif l:pline =~# '\s*typename\s*.*>\s*$'
        "    let l:retv = l:pindent - &shiftwidth
        "elseif l:pline =~# '^\s*namespace.*'
        "    let l:retv = 0
    endif
    return l:retv
endfunction

if has("autocmd")
    autocmd BufEnter *.{cc,cxx,cpp,h,hh,hpp,hxx} setlocal indentexpr=CppNoNamespaceAndTemplateIndent()
endif

" handle lambdafct indent correctly
autocmd BufEnter *.cpp :setlocal cindent cino=j1,(0,ws,Ws

" fct to remove trailing whitespaces
function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun

" auto remove on save for these file types
autocmd FileType sh,perl,python,cpp  :call <SID>StripTrailingWhitespaces()
