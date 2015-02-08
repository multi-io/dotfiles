# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# If running interactively, then:
if [ "$PS1" ]; then

# don't put duplicate lines in the history. See bash(1) for more options
# export HISTCONTROL=ignoredups

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

alias cvsfhg='cvs -d :ext:otter.isst.fhg.de:/home/oklischa/cvsroot'
alias cvsintbas='cvs -d :ext:otter.isst.fhg.de:/home/inetbas/repository'

alias jpython='jpython -Dpython.cachedir=/home/olaf/.jpython.d/cachedir'

# TODO: das ist suboptimal -- er sollte selber erkennen, ueber welchen Provider er eingewehlt ist.
alias wgetfhg='WGETRC=~/.wgetrc.fhg wget'

alias wgetwof='WGETRC=~/.wgetrc.wwwoffle wget'

alias wofcache='WGETRC=~/.wgetrc.wwwoffle wget -r -L -nd --delete-after'


# $PS1 wird aus mysterioesen Gruenden immer wieder ueberschrieben
#  (siehe meine Anfrage im Usenet)
export  PS1='\u@\h:\w\$ '

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

# run site-specific stuff
for f in `generate-site-specific-filenames .bashrc.`; do
  . "$f"
done

PATH="$oldpath"

# don't create core files
ulimit -c 0

if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

if [ -d "$HOME/perl5/bin" ]; then
    export PATH="$HOME/perl5/bin:$PATH"
    PERL_MB_OPT="--install_base \"$HOME/perl5\""; export PERL_MB_OPT;
    PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"; export PERL_MM_OPT;
fi
