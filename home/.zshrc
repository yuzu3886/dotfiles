function mkdir() {
  [[ -d "$1" ]] || command mkdir -p "$1"
}

mkdir "${XDG_CACHE_HOME}/zsh"
mkdir "${XDG_STATE_HOME}/zsh"

HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

typeset -g WORDCHARS=${WORDCHARS:s@/@@:s@=@@}

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt no_flow_control
setopt share_history

autoload -Uz compinit
compinit -C -d "${XDG_CACHE_HOME}/zsh/zcompdump"

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

bindkey -e

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

bindkey '^r' history-incremental-pattern-search-backward

unfunction mkdir

[ -f "${HOME}/.zshrc.local" ] && source "${HOME}/.zshrc.local"
