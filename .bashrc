export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH=$PATH:/opt/homebrew/bin/
export PATH="$PATH:/Users/pranavbansal/.local/bin"
export PATH="$PATH:/usr/local/bin"
export PATH="/opt/homebrew/opt/util-linux/bin:$PATH"

if [[ $- == *i* ]] && [ -t 1 ] && command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
  exec tmux new-session -s "term-$PPID-$$"
fi

eval "$(starship init bash)"
eval "$(fzf --bash)"

alias cls=clear
alias cat=bat
alias grep=rg
alias c=clocks
alias ba="bus arrivals"

alias ebashrc="vi ~/.bashrc"
alias sbashrc="source ~/.bashrc"
alias ealacritty="vi ~/.config/alacritty/alacritty.toml"
alias salacritty="alacritty msg config reload"
alias etmux="vi ~/.tmux.conf"
alias stmux="tmux source-file ~/.tmux.conf"


# git
alias gps="git push"
alias gpl="git pull"
alias gcm="git checkout main"
source "$HOME/.local/share/bash-completion/completions/git"
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent

# brew installations autocomplete
for script in /opt/homebrew/etc/profile.d/bash_completion.sh/*.sh; do
    if [ -r "$script" ]; then
      source "$script"
    fi
done

# py
alias vact="source .venv/bin/activate"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin

# ruby
export PATH=$PATH:/opt/homebrew/lib/ruby/gems/3.4.0/bin

# k8s
alias k=kubectl
source <(kubectl completion bash | sed 's/kubectl/k/g')
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

kns() {
  if [ -z "$1" ]; then
    echo "Available namespaces:"
    kubectl get namespaces --output=name
    echo ""
    echo "Usage: kns <namespace>"
    return 1
  fi
  kubectl config set-context --current --namespace="$1"
}

ktx() {
  if [ -z "$1" ]; then
    echo "Available contexts:"
    kubectl config get-contexts --output=name
    echo ""
    echo "Usage: ktx <context>"
    return 1
  fi
  kubectl config use-context "$1"
}

ksec () {
  local name="$1"
  if [[ -z "$name" ]]
  then
    echo "Usage: ksec <secret-name>" >&2
    return 1
  fi
  kubectl get secret "$name" -o json | jq -r '
  .data
  | to_entries[]
  | "\(.key): \(.value | @base64d)"
'
}

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm use --silent default

# rs
. "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"

# postgres
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"

source ~/.bashrc.local
