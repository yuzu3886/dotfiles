zmodload zsh/stat

function mkdir() {
  [[ -d "$1" ]] || command mkdir -p "$1"
}

mkdir "${XDG_CACHE_HOME}/zsh"
mkdir "${XDG_DATA_HOME}/zsh/completions"
mkdir "${XDG_STATE_HOME}/zsh"

if (( $+commands[rustup] )); then
  if [[ ! -f "${XDG_DATA_HOME}/zsh/completions/_rustup" ||
      `which rustup` -nt "${XDG_DATA_HOME}/zsh/completions/_rustup" ]]; then
    rustup completions zsh > "${XDG_DATA_HOME}/zsh/completions/_rustup"
    rustup completions zsh cargo > "${XDG_DATA_HOME}/zsh/completions/_cargo"
    rm -f "${XDG_CACHE_HOME}/zsh/zcompdump"
  fi
fi

typeset -U fpath

fpath=(
  "${XDG_DATA_HOME}/zsh/completions"
  ${fpath}
)

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
_zcompdump="${XDG_CACHE_HOME}/zsh/zcompdump"
if [[ -f "${_zcompdump}" ]] &&
    (( $(date +%s) - $(zstat +mtime -- "${_zcompdump}") < 86400 )); then
  compinit -C -d "${_zcompdump}"
else
  compinit -d "${_zcompdump}"
fi
unset _zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

bindkey -e

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

bindkey '^r' history-incremental-pattern-search-backward

# skim
if (( $+commands[sk] )); then
  function skim-select-history() {
    BUFFER="$(history -r -n 1 | sk --reverse)"
    CURSOR=${#BUFFER}
    zle reset-prompt
  }
  zle -N skim-select-history
  bindkey '^r' skim-select-history

  function skim-cd-repo() {
    local repo="$(ghq list | sk --reverse)"
    if [ -n  "${repo}" ]; then
      fullpath="$(ghq list -p --exact ${repo})"
      BUFFER="cd ${fullpath/#$HOME/~}"
      zle accept-line
    fi
    zle clear-screen
  }
  zle -N skim-cd-repo
  bindkey '^]' skim-cd-repo
fi

unfunction mkdir

[ -f "${HOME}/.zshrc.local" ] && source "${HOME}/.zshrc.local"
