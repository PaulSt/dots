#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ct='cd ~/projects/tdgtp/'
alias l='ls -all --color=auto'
alias nh='nohup'
export UNI=~/Dropbox/uni
export PHD=~/Dropbox/uni/phd
export PATH=~/bin:$PATH

export NETGENDIR=~/ngsuite/ngsolve-install/bin
export PATH=$NETGENDIR:$PATH
export PYTHONPATH=$NETGENDIR/../lib/python3.7/site-packages:$PATH

export VISUAL=vim
export EDITOR="$VISUAL"
export GTAGSLABEL=pygments

export PATH=~/.local/bin:$PATH
export PATH=~/.local/lib:$PATH
export PYTHONPATH=~/.local/lib:$PYTHONPATH:$PATH

bind TAB:menu-complete
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind 'set completion-ignore-case on'

function cd {
    builtin cd "$@" && ls -F
    }

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

export PS1="\[\e[1;32m\]\W\[\e[m\] \[\e[1;31m\]\`parse_git_branch\`\[\e[m\] \[\e[1;36m\]\\$\[\e[m\] "
