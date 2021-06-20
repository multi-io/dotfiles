source .zsh/functions.zsh

env_default 'LESS' '-R'

# make alt-backspace stop deleting at any non-alphanumeric character
WORDCHARS=''

## make Ctrl-W delete some additional characters as well
my-backward-delete-word() {
    local WORDCHARS="${WORDCHARS}-,.;'<>:\"[]{}/-=_+!$%^&*()";
    zle backward-delete-word;
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

# split words like bash does
setopt sh_word_split

autoload -U +X compinit && compinit

# re-bind <tab> to expand-or-complete-prefix rather than the default
# expand-or-complete. expand-or-complete-prefix will complete everything left
# of the cursor even if the cursor is in the middle of the word
bindkey '^i' expand-or-complete-prefix

# menu completion
zstyle ':completion:*' menu select

if [[ -f ~/.shrc ]]; then
    . ~/.shrc
fi
