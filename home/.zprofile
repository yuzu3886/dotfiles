export LANG="en_US.UTF-8"

export EDITOR="vim"
export VISUAL="$EDITOR"

export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"

export PATH="${HOME}/.local/bin:${PATH}"

# go
export PATH="${HOME}/go/bin:${PATH}"

# rust
export RUSTUP_HOME="${XDG_DATA_HOME}/rustup"
export CARGO_HOME="${XDG_DATA_HOME}/cargo"
export PATH="${CARGO_HOME}/bin:${PATH}"

# ssh-agent
if [[ -z "${SSH_AUTH_SOCK}" && -n "${XDG_RUNTIME_DIR}" ]]; then
  export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"
fi
