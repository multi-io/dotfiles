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

# run site-specific stuff
for f in `generate-site-specific-filenames .bashrc.`; do
  . "$f"
done

PATH="$oldpath"

# don't create core files
ulimit -c 0
