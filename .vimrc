unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set number
set tabstop=4
set shiftwidth=4
set expandtab
set clipboard=unnamed   " https://vim.fandom.com/wiki/Mac_OS_X_clipboard_sharing
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-tsserver', 'coc-python', 'coc-sh']
nmap <leader>rn <Plug>(coc-rename)

