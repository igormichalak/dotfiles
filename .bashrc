# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# Disable flow control (ctrl-s and ctrl-q).
stty -ixon

# Prompt customization.
BLACK="\[$(tput setaf 0)\]"
RED="\[$(tput setaf 1)\]"
GREEN="\[$(tput setaf 2)\]"
YELLOW="\[$(tput setaf 3)\]"
BLUE="\[$(tput setaf 4)\]"
MAGENTA="\[$(tput setaf 5)\]"
CYAN="\[$(tput setaf 6)\]"
WHITE="\[$(tput setaf 7)\]"
RESET="\[$(tput sgr0)\]"

PS1="${RED}[${YELLOW}\u${GREEN}@${BLUE}\h ${MAGENTA}\w${RED}]${RESET}$ "

# Environment variables.
export GPG_TTY="$(tty)"
export EDITOR='nvim'

# Path.
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$PATH:$HOME/.local/opt/odin"

# Enable vi keybindings for command line editing.
set -o vi

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

HISTFILE="$HOME/.bash_history"
HISTFILESIZE=20000
HISTSIZE=20000

# Before executing a command from history expansion, display it for verification.
shopt -s histverify

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Allows you to cd into directory merely by typing the directory name.
shopt -s autocd

# Enable color support of ls and grep.
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"

    alias ls='ls --color=auto --group-directories-first'
    alias grep='grep --color=auto'
fi

# Colored GCC warnings and errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Functions.
reload_configs() {
    source "$HOME/.bashrc"
    bind -f "$HOME/.inputrc"
    echo "Reloaded \".bashrc\" and \".inputrc\"."
}

cmd_exists() {
    type "$1" &> /dev/null
}

fzf_history() {
    if cmd_exists 'fzf'; then
        local command_to_run="$(history | tac | sort -k 1.8 -u | sort -n | fzf --tac --no-sort --bind 'ctrl-l:toggle-sort' | sed -E 's/ *[0-9]+ *//')"
        if [ -n "$command_to_run" ]; then
            READLINE_LINE="$command_to_run"
            READLINE_POINT="${#command_to_run}"
        else
            echo 'No command selected.'
        fi
    else
        echo 'fzf not found.'
    fi
}

# Bindings.
bind -x '"\C-r":"fzf_history"'

# Handy aliases.
alias config="$EDITOR $HOME/.bashrc"
alias reload='reload_configs'

alias get_idf=". $HOME/.local/opt/esp-idf/export.sh"

alias la='ls -A'
alias ll='ls -lh'
alias lx='ls -lhA'
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -v'
alias mkd='mkdir -pv'
alias ffmpeg='ffmpeg -hide_banner'

# Load environment.
cmd_exists zoxide && eval "$(zoxide init bash)"
cmd_exists opam && eval "$(opam env --switch=default)"

# Load desktop specific configuration.
if [ "$(hostname)" = "arc" ]; then
    source ~/.bashrc_desktop
fi

# Load Chromebook specific configuration.
if [ "$(hostname)" = "penguin" ]; then
    source ~/.bashrc_chromebook
fi

