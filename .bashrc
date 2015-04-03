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
        echo 'please install perl local::lib (https://metacpan.org/pod/local::lib)'
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

# run site-specific stuff
for f in `generate-site-specific-filenames .bashrc.`; do
  . "$f"
done
