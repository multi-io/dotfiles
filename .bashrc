# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -n "$_BASHRC_RAN" ]; then
    return
fi
_BASHRC_RAN=1

# Source global /etc/bashrc if present. Mainly for b/w compat. /etc/bash.bashrc (if present) is already executed automatically.
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

alias jpython='jpython -Dpython.cachedir=/home/olaf/.jpython.d/cachedir'

alias wgetwof='WGETRC=~/.wgetrc.wwwoffle wget'

alias wofcache='WGETRC=~/.wgetrc.wwwoffle wget -r -L -nd --delete-after'

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi



oldpath="$PATH"
PATH="/usr/local/bin:$PATH"

if [ -x "$(which virtualenv)" ]; then
    # virtualenv should use Distribute instead of legacy setuptools
    export VIRTUALENV_DISTRIBUTE=true
    # Centralized location for new virtual environments
    export PIP_VIRTUALENV_BASE=$HOME/virtualenvs
    # pip should only run if there is a virtualenv currently activated
    export PIP_REQUIRE_VIRTUALENV=true
    # cache pip-installed packages to avoid re-downloading
    export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache
fi


if [ -f ~/openrc ]; then
    . ~/openrc
fi


PATH="$oldpath"

# don't create core files
ulimit -c 0

if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [ "$SHLVL" = "1" ]; then
    if perl -e 'use local::lib' >/dev/null 2>&1 || perl "-I$HOME/perl5/lib/perl5" -e 'use local::lib' >/dev/null 2>&1 ; then
        eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"  # TODO not whitespace safe
    else
        echo 'please install perl local::lib (https://metacpan.org/pod/local::lib)' >&2
        export PATH="$HOME/perl5/bin:$PATH"
        PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
        PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
        export PERLLIB="$HOME/perl5/lib/perl5:$PERLLIB"
    fi
fi

jdk_switch() {
    if [ -z "$1" ]; then
        echo "usage: jdk_switch <java home directory name>" >&2;
        return;
    fi

    jh="$1"
    if [ ! -d "$jh" -o ! -x "$jh/bin/java" ]; then
        jh="/usr/local/$jh"
    fi

    if [ ! -d "$jh" -o ! -x "$jh/bin/java" ]; then
        echo "java home directory not found: $jh" >&2;
        return;
    fi

    echo "switching JAVA_HOME to $jh" >&2
    # try to remove the current $JAVA_HOME from $PATH
    if [ -x /usr/bin/ruby ]; then  # need to use the native ruby binary, not any rbenv shim, to get an unchanged $PATH in the script
        PATH=$(/usr/bin/ruby -e "print ENV['PATH'].gsub(\"#{ENV['JAVA_HOME']}/bin:\", '')")
    fi
    export JAVA_HOME="$jh"
    export PATH="$jh/bin:$PATH"
}

PATH="$HOME/bin:$PATH"

[[ -f ~/.tmux-session.load ]] && source ~/.tmux-session.load

[[ -n "$(type -p brew)" && -f $(brew --prefix)/etc/bash_completion ]] && . $(brew --prefix)/etc/bash_completion

# run site-specific stuff
for f in `generate-site-specific-filenames .bashrc.`; do
  . "$f"
done

