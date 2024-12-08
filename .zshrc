# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# get completions for brew-installed programs
# in some cases, e.g. git, they seem inferior?
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  # autoload -Uz compinit
  # compinit
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

if [[ ! -d "$ZSH" ]]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=()
if type -p kubectl >/dev/null; then
    KUBE_PS1_SEPARATOR=' '
    KUBE_PS1_DIVIDER=' '
    plugins+=(kubectl kube-ps1)
fi

source $ZSH/oh-my-zsh.sh

# TODO "uniquify" things like fpath, $FPATH and precmd_functions to make .zshrc re-sourceable

# User configuration

if type -p kubectl >/dev/null; then
    PROMPT=$PROMPT'$(kube_ps1) '
fi

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# help for zsh builtins
#unalias run-help
autoload run-help
alias help=run-help

# pre-prompt hook

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# split words like bash does
setopt sh_word_split

# vim mode
bindkey -v
export KEYTIMEOUT=1  # only has an effect outside tmux. Inside tmux, there's a corresponding tmux variable "escape-time"

# Change cursor shape for different vi modes
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
}
zle -N zle-line-init

# Edit line in vim with ctrl-t
autoload edit-command-line; #zle -N edit-command-line
bindkey '^t' edit-command-line
bindkey -M vicmd '^t' edit-command-line
# TODO beam shaped cursor after exiting edit-command-line

# bindkey -M vicmd '^[[P' vi-delete-char
# bindkey -M visual '^[[P' vi-delete

bindkey -M viins '^p' up-line-or-history
bindkey -M vicmd '^p' up-line-or-history
bindkey -M viins '^n' down-line-or-history
bindkey -M vicmd '^n' down-line-or-history

# ctrl-r is obv. already taken in vi
bindkey -M viins '^f' history-incremental-search-backward
bindkey -M vicmd '^f' history-incremental-search-backward
# N.B. in command mode, can also use / and ? + n/N to search through the history, but w/o interactivity as you type
# use `bindkey -L -M vicmd` to see all keybindings in command mode

# in incremental searches, make "Enter" put the chosen thing in the editor but DON'T run it immediately
bindkey -M isearch '^M' accept-search

# retain some navigation keystrokes in insert mode
bindkey -M viins "^a" beginning-of-line
bindkey -M viins "^e" end-of-line
bindkey -M viins '^d' delete-char
bindkey -M viins '^[\177' backward-delete-word  # option-backspace
bindkey -M viins '^[h' backward-char  # option-h
bindkey -M viins '^[l' forward-char  # option-l
bindkey -M viins '^[b' backward-word  # option-b and option-left
bindkey -M viins '^[w' forward-word  # option-w
bindkey -M viins '^[f' forward-word  # option-f and option-right

## make Ctrl-W delete some additional characters compared to option-backspace
my-backward-delete-word() {
    WORDCHARS="${WORDCHARS}-,.;'<>:/\"[]{}-=_+!$%^&*()" zle backward-delete-word;
}
zle -N my-backward-delete-word
bindkey -M viins '^w' my-backward-delete-word

function my_precmd() {
    # (sys11) in tmux, turn pane bg red when we connect to prod
    if [[ -n "$TMUX_PANE" ]]; then
        if [[ "$ENVIRONMENT" = "prod" || "$KUBECONFIG" = "${HOME}/.kube/configs/kubeconfig-metakube" ]]; then
            tmux set -p window-style 'bg=#500000'
        else
            tmux set -p -u window-style
        fi
    fi

    # beam-shaped cursor at the start of every prompt TODO doesn't work
    echo -ne "\e[5 q"
}

typeset -a precmd_functions
precmd_functions+=(my_precmd)

if [[ -f ~/.shrc ]]; then
    . ~/.shrc
fi

if [[ -d "$HOME/.zshrc.d" ]]; then
    find "$HOME/.zshrc.d" -mindepth 1 -maxdepth 1 -type f -name '*.sh' | sort | while read script; do
        . "$script"
    done
fi

PROMPT+="
$(echo $'%B#>%b') "
