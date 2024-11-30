unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

set number
set tabstop=4
set shiftwidth=4
set expandtab
let g:coc_global_extensions = ['coc-json', 'coc-git', 'coc-tsserver', 'coc-python', 'coc-sh']
nmap <leader>rn <Plug>(coc-rename)

set nofixeol
