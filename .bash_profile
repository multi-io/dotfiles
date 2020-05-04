# ~/.bash_profile: executed by bash(1) for login shells.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

if [ -n "$_BASH_PROFILE_RAN" ]; then
    return
fi
_BASH_PROFILE_RAN=1

umask 022

# include .bashrc if it exists
# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
#if [ -d ~/bin ] ; then
#    PATH=~/bin:"${PATH}"
#fi

# do the same with MANPATH
#if [ -d ~/man ]; then
#    MANPATH=~/man:"${MANPATH}"
#fi
# .bash_profile

if [ -f ~/.profile ]; then
	. ~/.profile
fi

# User specific environment and startup programs

export PATH=.:`generate-site-specific-filenames -n $HOME/bin/ | tr ' ' ':'`:$HOME/bin:$PATH
export ENV=$HOME/.bashrc
#export TEMP=$HOME/temp
export USERNAME="Olaf Klischat"
export SPICECAD_HELPDIR=/usr/local/spicecad
export CVSROOT=$HOME/cvsroot
export EDITOR=emacs_or_fallback.sh
export JCLASSES=~/java/jclasses/sun
export JAC_HOME=/usr/local/jacorb
#export MANPATH=$MANPATH:/usr/local/ocs/man
#export HTTP_PROXY='http://tick:8080'
export BROWSER=firefox


export CS=basta.cs.tu-berlin.de
export CSHP='http://user.cs.tu-berlin.de/~klischat'
export CSCVS=':ext:basta.cs.tu-berlin.de:/home/k/klischat/cvsroot'
export ISST=deer.isst.fhg.de
export ISSTHP='http://www.isst.fhg.de/~oklischa'
export ISSTCVS=':ext:lion.isst.fhg.de:/home/oklischa/cvsroot'
export CDDA_DEVICE=/dev/cdrom

export CVS_RSH=ssh

export RSMHOME=/home/olaf/.rsm
export PERLLIB="$PERLLIB:$HOME/share/perl"

export RUBYLIB="$HOME/lib/ruby"

# there appears to be no easy way to set this
# on a per-project/per-directory basis
export GTAGSLIBPATH=/usr/local/src/gtk2:/usr/local/src/gdk2:/usr/local/src/gdk-pixbuf2:/usr/local/src/glib2:/usr/local/src/libc6

export IRCNICK=multi_io
export HISTSIZE=10000

export GNUS_GNUSERV_PORT=$[ 30000 + $UID ];
export GNU_SECURE=$HOME/.gnuserv-trusted-hosts 

export WND_PPR=de/fhg/isst/ilog/wind/pilot/presentation
export WND_SND=de/fhg/isst/ilog/wind/pilot/sender
export WND_WRK="$HOME/workspace/IL WIND 2"
export WND="$HOME/wind/wind2"
export wind_common_resources=$HOME/workspace/wind3-resources
export project_common_resources=$HOME/workspace/wind3-resources

export LANG=en_US.UTF-8
export LC_CTYPE=$LANG    # in some environments (e.g. OSX?), for some reason, LC_CTYPE gets set to just UTF-8, which is broken

_krewroot="${KREW_ROOT:-$HOME/.krew}"
if [[ -n "$_krewroot" ]]; then
    export PATH="${_krewroot}/bin:$PATH"
fi
unset _krewroot
    

#if [ -e /usr/bin/xmms2-launcher ]; then
#  /usr/bin/xmms2-launcher
#fi

# run site-specific stuff
#for f in `generate-site-specific-filenames .bash_profile.`; do
#  . "$f"
#done
