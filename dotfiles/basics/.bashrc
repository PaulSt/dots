#
# ~/.bashrc
#

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ----------------------
# aliases
# ----------------------
alias ls='ls --color=auto -v'
alias l='ls -all --color=auto'
alias grep='grep --color=always'
alias nh='nohup'
alias sh='sshpass -f <(pass uni/univie.ac.at/plain) ssh stocker@logon.mat.univie.ac.at'
alias shy='sshpass -f <(pass uni/univie.ac.at/plain) ssh -Y stocker@logon.mat.univie.ac.at'
alias f5='f5fpc -s -t vpn.univie.ac.at:8443 -u stockerp31 -d /etc/ssl/certs/'

bind TAB:menu-complete
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind 'set completion-ignore-case on'

function cd {
    builtin cd "$@" && ls -F
    }

function za {
    nohup zathura "$1" >/dev/null 2>&1 &
    }

function sscp {
    scp stocker@logon.mat.univie.ac.at:"$1" .
    }

# ----------------------
# exports
# ----------------------
export UNI=~/Dropbox/uni
export PHD=~/Dropbox/uni/phd

export PATH=~/bin:$PATH
export PATH=~/bin/platform-tools:$PATH

export NETGENDIR=~/ngsuite/ngsolve-install/bin
export PATH=$NETGENDIR:$PATH
export PYTHONPATH=$NETGENDIR/../lib/python3.9/site-packages:$PATH

export VISUAL=vim
export EDITOR="$VISUAL"
export GTAGSLABEL=pygments

export PATH=~/.local/bin:$PATH
export PATH=~/.local/lib:$PATH
export PYTHONPATH=~/.local/lib:$PYTHONPATH:$PATH
export PATH=~/.local/lib/python3.9/site-packages:$PATH


export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

export PATH=~/mathematica:$PATH
export PATH=~/.gem/ruby/2.6.0/bin:$PATH

# ----------------------
# bash history.
# ----------------------
export HISTFILESIZE=1000000 #-1 for unlimited
export HISTSIZE=2000000 #-1 for unlimited
#export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

bind '"\e[A": history-search-backward'            # arrow up
bind '"\e[B": history-search-forward'             # arrow down


# ----------------------
# Git Helpers
# ----------------------
alias ga='git add -p'
alias gc='git commit'
alias gd='git diff'
alias gp='git pull'
alias gs='git status'
# Git log find by commit message
function glf() { git log --all --grep="$1"; }

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

export PS1="\[\e[1;32m\]\h\[\e[m\]\[\e[1;32m\]:\[\e[m\] \[\e[1;36m\]\W\[\e[m\] \[\e[1;31m\]\`parse_git_branch\`\[\e[m\]\[\e[1;32m\]\\$\[\e[m\] "
