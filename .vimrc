" general
    " do not back up
        set nobackup
        set noswapfile
    " use linux clipboard
        set clipboard=unnamed,autoselect
    " store history for 50 before
        set history=50
    " mouse enabled
        set mouse=a
    " search config
        " hilight
            set hlsearch
        " don't care upper and lower case
            set ignorecase
            set smartcase
        " jump end to start
            set wrapscan
    " when quit insert mode, make IME desabled
        set iminsert=1
    " scroll off in under 10th line
        set scrolloff=10
" Space, Tab, char-width, indent
    " make visible Space
        set list
        set listchars=trail:.
    "  zenkaku-char-width force to be 2 chars width
        set ambiwidth=double
    " Tab to Space
        set expandtab
        set tabstop=4
        set shiftwidth=4
        set softtabstop=4
    " indent management
        set autoindent
    " backSpace enabled
        set backspace=indent,eol,start
" user function
    " foldexpr
        " Blank
            function Blank(line)
                return getline(a:line)=~'^\s*$'
            endfunction
        " HasMarker
            function HasMarker(line)
                let text=getline(a:line)
                if text=~'@nofold'
                    return 0
                elseif &filetype=='vim'
                    let marker='^\s*"'
                elseif &filetype=='python'
                    let marker='import\|.*:$\|@'
                else
                    let marker='^.'
                endif

                return match(text, marker)!=-1
            endfunction
        " HasAntiMarker
            function HasAntiMarker(line)
                let text=getline(a:line)
                if text=~'@nofold'
                    return 0
                elseif &filetype=='vim'
                    let marker='$^'
                elseif &filetype=='python'
                    let marker='else\|elif\|except'
                else
                    let marker='$^'
                endif

                return match(text, marker)!=-1
            endfunction
        " FirstFold
            function FirstFold(line)
                if !HasMarker(a:line)
                    return 0
                elseif HasAntiMarker(a:line)
                    return 0
                elseif HasMarker(a:line-1)
                    return 0
                else
                    return 1
                endif
            endfunction
        " FoldLevel
            function FoldLevel(line)
                if Blank(a:line)&&a:line>=line("$")
                    return 0
                elseif Blank(a:line)&&HasMarker(a:line+1)
                    return FoldLevel(a:line+1)-1
                elseif Blank(a:line)
                    return FoldLevel(a:line+1)
                else
                    return indent(a:line)/&shiftwidth+HasMarker(a:line)
                endif
            endfunction
        " MyFoldExpr
            function MyFoldExpr(line)
                if FirstFold(a:line)
                    return '>'.FoldLevel(a:line)
                else
                    return FoldLevel(a:line)
                endif
            endfunction
    " foldtext
        " MyFoldText
            function MyFoldText()
                let maintext=substitute(getline(v:foldstart), '^\s*', '', 'g')
                let lines='['.(v:foldend-v:foldstart+1).' lines]'
                let indent=substitute( repeat( '   ╎', v:foldlevel), '^\s*', '', 'g')
                return indent.maintext.'...'.lines
            endfunction
    " FoldLeft
        function FoldLeft()
            if col(".")==1&&FoldLevel(line("."))!=0
                foldclose
            endif
            call cursor(line("."), col(".")-1)
        endfunction
    " ExpandRight
        function ExpandRight()
            if FoldLevel(line("."))!=0&&foldclosed(line("."))!=-1
                foldopen
            else
                call cursor(line("."), col(".")+1)
            endif
        endfunction
" vim-plug
    " call plug
        call plug#begin('~/.vim/plugged')
    " file system
        Plug 'scrooloose/nerdtree'
    " processing
        " trigger
            Plug 'thinca/vim-quickrun'
        " async processing
            Plug 'Shougo/vimproc.vim', {'do': 'make'}
        " extention of vimproc
            Plug 'osyo-manga/shabadou.vim'
        " smart hilight error
            Plug 'cohama/vim-hier'
    " text operating
        " complete
            Plug 'shougo/neocomplete.vim'
        " braket managing
            Plug 'kana/vim-smartinput'
        " comment
            Plug 'tomtom/tcomment_vim'
        " new textobject
            Plug 'kana/vim-textobj-user'
    " looking
        " theme manager
            Plug 'itchyny/lightline.vim'
        " theme
            Plug 'crusoexia/vim-dracula'
        " make indent visible
            Plug 'Yggdroot/indentLine'
    " for python
        " syntax
            Plug 'davidhalter/jedi-vim', {'for': 'python'}
        " pep8 check
            Plug 'andviro/flake8-vim', {'for': 'python'}
        " indent automation
            Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
        " make indent-block textoblect
            Plug 'kana/vim-textobj-indent', {'for': 'python'}
        " extention of textobject for python
            Plug 'bps/vim-textobj-python', {'for': 'python'}
    " end plug
        call plug#end()
" quickrun
    " set runnner to vimproc and some fix
        let g:quickrun_config = get(g:, 'quickrun_config', {})
        let g:quickrun_config._ = {
        \ 'runner'    : 'vimproc',
        \ 'runner/vimproc/updatetime' : 60,
        \ 'outputter' : 'error',
        \ 'outputter/error/success' : 'buffer',
        \ 'outputter/error/error'   : 'quickfix',
        \ 'outputter/buffer/split'  : ':rightbelow 8sp',
        \ 'outputter/buffer/close_on_empty' : 1,
        \ }
    "  <C-c> stop runnning
        nnoremap <expr><silent> <C-c> quickrun#is_running() ? quickrun#sweep_sessions() : '<C-c>'
" looking
    " config for lightline
        set laststatus=2
        set t_Co=256
    " use dracula sheme
        let g:lightline={'colorscheme': 'Dracula'}
        colorscheme dracula
        set background=dark
    " hilight cursor line
        set cursorline
    " make syntax enebled
        syntax enable
    " show line number
        set number
    " show title
        set title
    " menu hilight
        set wildmenu
    " fold text
        set foldmethod=expr
        set foldexpr=MyFoldExpr(v:lnum)
        set foldtext=MyFoldText()
        set foldlevel=1
        set fillchars=vert:\|
        highlight Folded ctermfg=37 ctermbg=235
" mapping
    " kill Q
        nnoremap Q <nop>
    " use oj and ok
        nnoremap o <nop>
        nnoremap oj o
        nnoremap ok O
    " exchange j and gj
        nnoremap j gj
        nnoremap k gk
        vnoremap j gj
        vnoremap k gk
        nnoremap gj j
        nnoremap gk k
        vnoremap gj j
        vnoremap gk k
    " put jj to quit input mode
        inoremap jj <Esc>
    " fold and expand on h and l respectively
        nnoremap <silent> h :call FoldLeft()<CR>
        nnoremap <silent> l :call ExpandRight()<CR>
    " tab managing
        " split tab
            nnoremap <silent> ss :split<CR>
            nnoremap <silent> sv :vsplit<CR>
        " split new tab
            nnoremap <silent> sns :split<Space>new<CR>
            nnoremap <silent> snv :vsplit<Space>new<CR>
        " jamping tab
            nnoremap sj <C-w>j
            nnoremap sk <C-w>k
            nnoremap sh <C-w>h
            nnoremap sl <C-w>l
        " moving tab
            nnoremap sJ <C-w>J
            nnoremap sK <C-w>K
            nnoremap sH <C-w>H
            nnoremap sL <C-w>L
        " split size management
            nnoremap s< <C-w><
            nnoremap s> <C-w>>
            nnoremap s+ <C-w>+
            nnoremap s- <C-w>-
    " stop hilight
        nnoremap <silent> <Esc><Esc> :noh<CR>
    " use Space, Tab
        nnoremap <Space> <nop>
        nnoremap <Space>h ^
        nnoremap <Space>l $
        nnoremap <Space><CR> +i<CR><Esc>
        nnoremap <Space><Tab> >>
        nnoremap <Space><space> i<Space><Esc>
        nnoremap <silent> <Space>f :NERDTreeToggle<CR>
" python
    " protect <leader>r from jedi-vim
        command! -nargs=0 JediRename :call jedi#rename()
        let g:jedi#rename_command = ' ' 
        nmap <silent> <Space>r :JediRename<CR>
