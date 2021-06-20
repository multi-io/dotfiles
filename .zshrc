## make Ctrl-W delete some additional characters as well
my-backward-delete-word() {
    local WORDCHARS="${WORDCHARS}-,.;'<>:\"[]{}-=_+!$%^&*()";
    zle backward-delete-word;
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

# split words like bash does
setopt sh_word_split

autoload -U +X compinit && compinit

if [[ -f ~/.shrc ]]; then
    . ~/.shrc
fi
