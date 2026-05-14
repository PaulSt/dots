#
# ~/.bashrc
#

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    startx
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ----------------------
# jump
# ----------------------
# eval "$(jump shell bash)"

# ----------------------
# trash
# ----------------------
#alias rm=trash

# ----------------------
# aliases
# ----------------------
alias ls='ls --color=auto -v'
alias l='ls -all --color=auto'
alias grep='grep --color=always --exclude=tags'
alias untar='tar -zxvf'
alias v="nvim"
alias vim="nvim"
alias jpn='jupyter notebook'


bind TAB:menu-complete
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set menu-complete-display-prefix on'
bind 'set completion-ignore-case on'

# ----------------------
# helper functions
# ----------------------
# Open: text in nvim, everything else via xdg-open
o() {
  local f m
  for f; do
    m=$(file --mime-type -Lb -- "$f")
    case "$m:$f" in
      text/*|application/json:*|application/xml:*|application/*yaml:*|*:*.tex|*:*.md|*:*.py|*:*.sh|*:*.c|*:*.cpp|*:*.h|*:*.hpp)
        nvim -- "$f" ;;
      *)
        xdg-open "$f" >/dev/null 2>&1 & ;;
    esac
  done
}

# cd and list
cd() {
  builtin cd "$@" && ls -F
}

# Detached helpers
za() { nohup zathura "$@" >/dev/null 2>&1 & }
sth() { nohup st -e "$SHELL" -lc "cd $(printf '%q' "$PWD"); exec $SHELL" >/dev/null 2>&1 & }

# PDF rename
pdfr() {
  pdfrenamer -f "{Aall} - {T} ({YYYY})" "$@"
}

# Remove audio in-place, with backup during conversion
rmaudio() {
  local f=$1 b
  [[ -f "$f" ]] || { echo "Usage: rmaudio <file>"; return 1; }
  b="$f.bak"
  mv -- "$f" "$b" &&
    ffmpeg -i "$b" -c copy -an "$f" &&
    rm -- "$b"
}

# Compress mp4, remove audio; optional CRF, default 28
cmp4() {
  local in=$1 crf=${2:-28} out
  [[ -f "$in" ]] || { echo "Usage: cmp4 <file> [crf]"; return 1; }
  out="${in%.*}_compressed.mp4"
  du -h -- "$in"
  ffmpeg -i "$in" -vcodec libx264 -crf "$crf" -preset slow -an -movflags +faststart "$out"
  du -h -- "$out"
}

# nohup wrapper: nh cmd args...  OR  nh -l logfile cmd args...
nh() {
  local log=
  [[ $1 == -l || $1 == --log ]] && { log=$2; shift 2; }
  (($#)) || { echo "Usage: nh [-l logfile] <command> [args...]"; return 1; }

  if [[ -n $log ]]; then
    nohup "$@" >"$log" 2>&1 &
    echo "Started: $*"
    echo "Log: $log"
  else
    nohup "$@" >/dev/null 2>&1 &
    echo "Started: $*"
  fi
  echo "PID: $!"
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
export PATH=$NETGENDIR:$PATH
export PYTHONPATH=$NETGENDIR/../lib/python3.14/site-packages:$PATH


#source /etc/profile.d/petsc.sh # for petsc environment variables
#source /etc/profile.d/slepc.sh # for petsc environment variables
#export PETSC_DIR=/usr
#export SLEPC_DIR=/usr/local/slepc/usr
#export PETSC_DIR=/opt/petsc/linux-c-opt
#export SLEPC_DIR=/opt/slepc/linux-c-opt
#export PYTHONPATH=$PYTHONPATH:/opt/petsc/linux-c-opt/lib

export CC=/usr/bin/clang
export CXX=/usr/bin/clang++

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
export HISTFILESIZE=10000000 #-1 for unlimited
export HISTSIZE=-1 #-1 for unlimited
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
# fzf
# ----------------------
[ -r /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash

export FZF_DEFAULT_OPTS='--layout=reverse --height=40% --border'

fp() {
  [[ -d "$1" ]] && tree -C -L 2 -- "$1" 2>/dev/null | head -200 && return
  bat --color=always --style=numbers --line-range=:250 -- "$1" 2>/dev/null \
    || sed -n '1,160p' -- "$1" 2>/dev/null
}
export -f fp

cc() {
  local d
  d="$({ echo .; fd -td --strip-cwd-prefix --no-require-git; } |
    fzf --prompt='cd> ' --preview='fp {}')" && cd -- "$d"
}

oo() {
  local f files
  files="$(fd -tf --strip-cwd-prefix --no-require-git |
    fzf --multi --prompt='open> ' --preview='fp {}')" || return

  while IFS= read -r f; do
    [[ -n "$f" ]] && o "$f"
  done <<< "$files"
}

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
