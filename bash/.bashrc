#
# ~/.bashrc
#

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# jump
# eval "$(jump shell bash)"
# fzf
source /usr/share/fzf/key-bindings.bash
source /usr/share/fzf/completion.bash
# vtop
alias top='vtop'
# trash
#alias rm=trash

# ----------------------
# aliases
# ----------------------
alias ls='ls --color=auto -v'
alias l='ls -all --color=auto'
alias grep='grep --color=always --exclude=tags'
alias nh='nohup'
alias untar='tar -zxvf'
alias v="nvim"
alias vim="nvim"
alias jpn='jupyter notebook'


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

function sth {
    nohup st -e "$SHELL" -c "cd $PWD; exec $SHELL" >/dev/null 2>&1 &
    #st -t "$title" -e "$SHELL" -c "cd $PWD; exec $SHELL"
    }

# ----------------------
# exports
# ----------------------
export PATH=~/bin:$PATH
export PATH=~/bin/platform-tools:$PATH
export PATH=~/bin/remarkable/remarkable-cli-tooling:$PATH
export PATH=~/src/paraview_build/bin:$PATH

export READER=zathura

export BASEDIR=~/ngsuite
export NETGENDIR=~/ngsuite/ngsolve-install/bin
#export NETGENDIR=~/Documents/ngsuite/ngsolve-2401/bin
export PATH=$NETGENDIR:$PATH
export PYTHONPATH=$NETGENDIR/../lib/python3.12/site-packages:$PATH

export PETSC_DIR=/opt/petsc/linux-c-opt
export SLEPC_DIR=/opt/slepc/linux-c-opt
export PYTHONPATH=$PYTHONPATH:/opt/petsc/linux-c-opt/lib

#export CC=/usr/bin/clang
#export CXX=/usr/bin/clang++

export VISUAL=vim
export EDITOR="$VISUAL"
export GTAGSLABEL=pygments

export PATH=~/.local/bin:$PATH

#export MKL_NUM_THREADS=1
#export OPENBLAS_NUM_THREADS=1

export PATH=~/.local/share/gem/ruby/3.0.0/bin:$PATH
export GEM_HOME=$HOME/.gem
export PATH=$PATH:/home/paul/.gem/ruby/3.0.0/bin
export PATH=$PATH:$HOME/.gem/bin
export NPM_CONFIG_PREFIX=~/.npm-global
export PATH=~/.npm-global/bin:$PATH

#export PATH="/usr/lib/ccache/bin/:$PATH"


# ----------------------
# SSH agent
# ----------------------
ssh_pid_file="$HOME/.config/ssh-agent.pid"
SSH_AUTH_SOCK="$HOME/.config/ssh-agent.sock"
if [ -z "$SSH_AGENT_PID" ]
then
	# no PID exported, try to get it from pidfile
	SSH_AGENT_PID=$(cat "$ssh_pid_file")
fi

if ! kill -0 $SSH_AGENT_PID &> /dev/null
then
	# the agent is not running, start it
	rm "$SSH_AUTH_SOCK" &> /dev/null
	>&2 echo "Starting SSH agent, since it's not running; this can take a moment"
	eval "$(ssh-agent -s -a "$SSH_AUTH_SOCK")"
	echo "$SSH_AGENT_PID" > "$ssh_pid_file"
	#ssh-add -A 2>/dev/null
	ssh-add ~/.ssh/key 2>/dev/null

	>&2 echo "Started ssh-agent with '$SSH_AUTH_SOCK'"
fi
export SSH_AGENT_PID
export SSH_AUTH_SOCK

# ----------------------
# bash history.
# ----------------------
export HISTFILESIZE=1000000 #-1 for unlimited
export HISTSIZE=2000000 #-1 for unlimited
#export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.bash_history
export HISTCONTROL=ignoreboth:erasedups
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
#PROMPT_COMMAND="history -a; history -n; $PROMPT_COMMAND"

bind '"\e[A": history-search-backward'            # arrow up
bind '"\e[B": history-search-forward'             # arrow down

h() {
    grep -a $@ ~/.bash_history | sort --unique
}

function ff() { find . 2>/dev/null | grep -i $@; }


# ----------------------
# Git Helpers
# ----------------------
alias ga='git add -p'
alias gc='git commit'
alias gd='git diff -w'
alias gdc='git diff -w --cached'
alias gp='git pull'
alias gs='git status'
alias gl='git log --stat'
alias ganw="git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero"
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
