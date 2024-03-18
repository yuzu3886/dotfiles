mkdir_p () {
  [[ -d "$1" ]] || mkdir -p "$1"
}

mkdir_p ${XDG_CACHE_HOME}/zsh
mkdir_p ${XDG_DATA_HOME}/zsh/completions
mkdir_p ${XDG_STATE_HOME}/zsh

# path
typeset -U PATH path fpath

path=(
  ${HOME}/.local/bin
  ${path[@]}
)

fpath=(
  ${XDG_DATA_HOME}/zsh/completions
  ${fpath[@]}
)

# deno
export DENO_INSTALL=${XDG_DATA_HOME}/deno
export PATH=${DENO_INSTALL}/bin:$PATH

# rust
export CARGO_HOME=${XDG_DATA_HOME}/cargo
export RUSTUP_HOME=${XDG_DATA_HOME}/rustup
export PATH=${CARGO_HOME}/bin:$PATH

autoload -Uz compinit
compinit -C -d ${XDG_CACHE_HOME}/zsh/zcompdump

HISTFILE=${XDG_STATE_HOME}/zsh/history
HISTSIZE=100000
SAVEHIST=100000

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify
setopt ignore_eof
setopt magic_equal_subst
setopt no_beep
setopt no_flow_control
setopt share_history

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select=1

PROMPT="
%(?.%F{green}.%F{red})│%f %~
%(?.%F{green}.%F{red})│%f "

bindkey -e

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey '^p' history-beginning-search-backward-end
bindkey '^n' history-beginning-search-forward-end

bindkey '^r' history-incremental-pattern-search-backward
bindkey '^s' history-incremental-pattern-search-forward

# abbr
expand-alias-and-accept() {
  zle _expand_alias
  zle accept-line
}

expand-alias-and-insert() {
  zle _expand_alias
  zle self-insert
}

zle -N expand-alias-and-accept
zle -N expand-alias-and-insert
bindkey '^m' expand-alias-and-accept
bindkey ' '  expand-alias-and-insert

alias g='git'
