" c: Automatically break comments using the textwidth value.
" r: Automatically insert the comment leader when hitting <Enter> in insert mode.
" o: Automatically insert the comment leader when hitting 'o' or 'O' in normal mode.
" n: Recognize numbered lists. When hitting <Enter> in insert mode.
" m: Automatically break the current line before inserting a new comment line.
set formatoptions+=cronm

" This sets the width of a tab character to 4 spaces.
set tabstop=4

" This sets the number of spaces used when the <Tab> key is pressed in insert
" mode to 4.
set softtabstop=4

" This sets the number of spaces used for each indentation level when using
" the '>' and '<' commands, as well as the autoindent feature.
set shiftwidth=4

" This setting enables automatic indentation, which will copy the indentation
" of the current line when starting a new line.
set autoindent
set smartindent

" This disables the automatic conversion of tabs to spaces when you press the
" <Tab> key.
set expandtab
set smarttab

" Save 1,000 items in history
set history=1000

" Show the line and column number of the cursor position
set ruler

" Display the incomplete commands in the bottom right-hand side of your screen.  
set showcmd

" Display completion matches on your status line
set wildmenu

" Show a few lines of context around the cursor
set scrolloff=5

" Highlight search matches
set hlsearch

" Enable incremental searching
set incsearch

" Ignore case when searching
set ignorecase

" Override the 'ignorecase' option if the search pattern contains upper case characters.
set smartcase

" This enables the use of the mouse in all modes (normal, visual, insert,
" command-line, etc.).
set mouse=a

" This displays line numbers in the left margin.
set number

" This disables the creation of backup files.
set nobackup

" To allow moving to different buffer without saving the current buffer.
set hidden


" This disables the creation of swap files.
set noswapfile

" Automatically reload files when they change
set autoread

" Enable spell checking
set spell
set spelllang=en

" Highlight the current line
set cursorline

" Highlight the 100th column
set colorcolumn=100

" Set text width to 100
set textwidth=100

" This maps the '<' and '>' keys in visual mode to shift the selected text one
" shift width to the left or right and reselect the shifted text.
vnoremap < <gv
vnoremap > >gv

" The next four lines define key mappings for switching between windows using
" Ctrl + hjkl keys
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" The next four lines define key mappings for resizing windows using Alt +
" hjkl keys:
map <a-l> :vertical res -5<CR>
map <a-h> :vertical res +5<CR>
map <a-j> :res -5<CR>
map <a-k> :res +5<CR>

" These lines define key mappings for moving the cursor 10 spaces at a time
" using Shift + arrow keys:
nmap <S-l> 10l<CR>
nmap <S-h> 10h<CR>
nmap <S-j> 10j<CR>
nmap <S-k> 10k<CR>

" Enable folding
set foldenable
" Configure fold method
set foldmethod=marker
" Set the fold level to start with all folds open
set foldlevelstart=99
" Set the fold nesting level (default is 20)
set foldnestmax=10
" Automatically close folds when the cursor leaves them
set foldclose=all
" Open folds upon all motion events
set foldopen=all





" To install vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" To install using vim-plug: :PlugInstall
" To install the plugin


call plug#begin()

    Plug 'dense-analysis/ale' " linting and fixing code.
    "Plug 'airblade/vim-gitgutter' " a git diff in the sign colomn.
    Plug 'habamax/vim-asciidoctor' " Feature-full environment for ASCII Docs.
    Plug 'majutsushi/tagbar'       " Utility to easily browse the tag.
    Plug 'mbbill/undotree'         " Utility to view undo history
    Plug 'morhetz/gruvbox'         " retro-inspired color scheme
    Plug 'luochen1990/rainbow'     " For rainbow coloring of Parentheses
    Plug 'preservim/nerdtree'      " A filesystem explorer
    Plug 'puremourning/vimspector' " A multi-language debugging plugin
    Plug 'tpope/vim-dispatch'      " A plugin for async executing long-running commands
    Plug 'tpope/vim-fugitive'      " A popular Git Wrapper.
    Plug 'tpope/vim-speeddating'   " A plugin that allow you to quickly adjust dates.
    Plug 'vim-airline/vim-airline' " A lightweight and customizable status line.
    Plug 'vim-airline/vim-airline-themes' " Themes for airline
    Plug 'vim-scripts/c.vim'       " A packages of tools for C and C++.
    Plug 'vimwiki/vimwiki'         " A personal wiki plugin for Vim.
    Plug 'voldikss/vim-floaterm'   " A plugin for floating terminal inside vim.
    Plug 'tpope/vim-commentary' " Commenting tool
    Plug 'vim-scripts/DoxygenToolkit.vim' " Doxygen support
    Plug 'vim-scripts/SpellCheck' " Spell checking
    Plug 'ludovicchabant/vim-gutentags' " for tag managements for projects
    Plug 'skywind3000/gutentags_plus'   " Working with gtags and cscope
call plug#end()


" Plugin enable option


" For dense-analysis/ale - linting
" Ignore git commit when linting (highly annoying)
let g:ale_pattern_options = {
    \       'COMMIT_EDITMSG$': {'ale_linters': [], 'ale_fixers': []}
    \   }
let g:ale_linters = {
    \   'yaml': ['yamllint'],
    \   'cpp': ['clangtidy'],
    \   'c': ['clangtidy'],
    \   'asciidoc': ['cspell'],
    \   'markdown': ['cspell']
    \   }
let g:ale_fixers = {
    \   'cpp': ['clang-format'],
    \   'c': ['clang-format']}
 
" Automatic fixing
autocmd FileType c nnoremap <leader>f <Plug>(ale_fix)
 
" General settings
let g:ale_linters_explicit = 1
let g:ale_completion_enabled = 1
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_set_balloons=1
let g:ale_hover_to_floating_preview=1
let g:ale_use_global_executables = 1
let g:ale_sign_column_always = 1
let g:ale_disable_lsp = 1
 
" C++ linting
let g:ale_cpp_clangtidy_options = '-checks=-*,cppcoreguidelines-*'
let g:ale_cpp_clangtidy_checks = ['readability-*,performance-*,bugprone-*,misc-*']
let g:ale_cpp_clangtidy_checks += ['clang-analyzer-cplusplus-doc-comments']
 
" C linting
let g:ale_c_clangtidy_options = '-checks=-*,cppcoreguidelines-*'
let g:ale_c_clangtidy_checks = ['readability-*,performance-*,bugprone-*,misc-*']
let g:ale_c_clangtidy_checks += ['-readability-function-cognitive-complexity']
let g:ale_c_clangtidy_checks += ['-readability-identifier-length']
let g:ale_c_clangtidy_checks += ['-misc-redundant-expression']
let g:ale_c_build_dir_names = ['build', 'release', 'debug']
 
" This function searches for the first clang-tidy config in parent directories and sets it
function! SetClangTidyConfig()
    let l:config_file = findfile('.clang-tidy', expand('%:p:h').';')
    if !empty(l:config_file)
        let g:ale_c_clangtidy_options = '--config=' . l:config_file
        let g:ale_cpp_clangtidy_options = '--config=' . l:config_file
    endif
endfunction
 
" Run this for c and c++ files
autocmd BufRead,BufNewFile *.c,*.cpp,*.h,*.hpp call SetClangTidyConfig()

" Set this. Airline will handle the rest.
" let g:airline#extensions#ale#enabled = 1
let g:airline_theme = 'dark'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'default'


" For mbbill/undotree: quick undo access
nmap <F5> :UndotreeToggle<CR>


" For tpope/vim-fugitive - git integration.

nnoremap <Leader>gg :Git<CR>
nnoremap <Leader>gs :Git status<CR>
nnoremap <Leader>gc :Git commit<CR>
nnoremap <Leader>gb :Git blame<CR>
nnoremap <Leader>gd :Git difftool<CR>
nnoremap <Leader>gm :Git mergetool<CR>
nnoremap <Leader>gdv :Gvdiffsplit<CR>
nnoremap <Leader>gdh :Gdiffsplit<CR>


" vim-airline:vim-airline: the status line for vim
let g:airline_powerline_fonts = 1




" For preservim/nerdtree: the battle tested file explorer
let g:NERDTreeWinSize = 30
nnoremap <C-n> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.o$', '\.obj$', '\.a$', '\.so$', '\.out$', '\.git$']
let NERDTreeShowHidden = 1


" For majutsushi/tagbar: the ultimate tag bar
nmap <F8> :TagbarToggle<CR>



" For morhetz/gruvbox
"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX) && getenv('TERM_PROGRAM') != 'Apple_Terminal')
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif
syntax enable
set background=dark
autocmd vimenter * ++nested colorscheme gruvbox



" For rainbow coloring of Parentheses
let g:rainbow_active = 1 "set to 0 if you want to enable it later via :RainbowToggle




" habamax/vim-asciidoctor: Asciidoctor tools for vim
let g:asciidoctor_folding = 1
let g:asciidoctor_fold_options = 1
let g:asciidoctor_fenced_languages = ['vim', 'sh', 'python', 'c', 'javascript']




" voldikss/vim-floaterm: floating terminal
nnoremap <C-t> :FloatermToggle!<CR>
augroup FloatermMapping
    autocmd!
    autocmd FileType floaterm nnoremap <buffer> <Esc> <C-\><C-n>:FloatermToggle<CR>
    autocmd FileType floaterm inoremap <buffer> <Esc> <C-\><C-n>:FloatermToggle<CR>
augroup end
tnoremap <Esc> <C-\><C-n>:FloatermToggle<CR>




" For gtags and gtags_plus configuration
" enable gtags module
let g:gutentags_modules = ['ctags', 'gtags_cscope']

" config project root markers.
let g:gutentags_add_default_project_roots = 0
let g:gutentags_project_root = ['.root', '.git']

" generate datebases in my cache directory, prevent gtags files polluting my project
let g:gutentags_cache_dir = expand('~/.cache/tags')

" change focus to quickfix window after search (optional).
let g:gutentags_plus_switch = 1
"let g:gutentags_trace = 1
let g:gutentags_define_advanced_commands = 1

let g:gutentags_plus_nomap = 1
noremap <silent> <leader>css :GscopeFind s <C-R><C-W><cr>
noremap <silent> <leader>csg :GscopeFind g <C-R><C-W><cr>
noremap <silent> <leader>csc :GscopeFind c <C-R><C-W><cr>
noremap <silent> <leader>cst :GscopeFind t <C-R><C-W><cr>
noremap <silent> <leader>cse :GscopeFind e <C-R><C-W><cr>
noremap <silent> <leader>csf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>csi :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
noremap <silent> <leader>csd :GscopeFind d <C-R><C-W><cr>
noremap <silent> <leader>csa :GscopeFind a <C-R><C-W><cr>
noremap <silent> <leader>csz :GscopeFind z <C-R><C-W><cr>


" To install using Vundle: :PluginInstall
" For Vundle


set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'


" For YCM
Plugin 'ycm-core/YouCompleteMe'


" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
