export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH=$PATH:/opt/homebrew/bin/
export PATH="$PATH:/Users/pranavbansal/.local/bin"
export PATH="$PATH:/usr/local/bin"

if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ]; then
  exec tmux new-session -s "term-$PPID-$$"
fi

eval "$(starship init bash)"
eval "$(fzf --bash)"

alias cls=clear
alias cat=bat
alias grep=rg
alias c=clocks

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

vcreate() {
    # Default values
    PYTHON_VERSION=""
    ENV_NAME=".venv"

    # Parse arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --python) PYTHON_VERSION="$2"; shift ;;
            *) echo "Usage: vcreate [--python <version>]"; return 1 ;;
        esac
        shift
    done

    # If a Python version is specified, use pyenv to find the executable
    if [[ -n "$PYTHON_VERSION" ]]; then
        PYENV_PYTHON=$(pyenv versions --bare | grep -E "^$PYTHON_VERSION\$")

        if [[ -z "$PYENV_PYTHON" ]]; then
            echo "Python version $PYTHON_VERSION not found in pyenv. Install it using:"
            echo "  pyenv install $PYTHON_VERSION"
            return 1
        fi

        PYTHON_BIN="$(pyenv root)/versions/$PYTHON_VERSION/bin/python"
    else
        PYTHON_BIN="python"  # Default to system Python
    fi

    # Create the virtual environment
    echo "Creating virtual environment $ENV_NAME with Python $PYTHON_VERSION"
    $PYTHON_BIN -m venv $ENV_NAME

    echo "initializing directory with uv"
    uv init

    echo "installing dev dependencies with uv"
    uv add --dev isort black

    if [[ $? -eq 0 ]]; then
        echo "Virtual environment '$ENV_NAME' created with Python $PYTHON_VERSION"
        echo "Activate it using: source $ENV_NAME/bin/activate"
    else
        echo "Failed to create virtual environment."
    fi
}


# go
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:~/go/bin

# ruby
export PATH=$PATH:/opt/homebrew/lib/ruby/gems/3.4.0/bin

# k8s
alias k=kubectl
kns() {
  if [ -z "$1" ]; then
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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# rs
. "$HOME/.cargo/env"
export PATH="$HOME/.cargo/bin:$PATH"

# py
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# postgres
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"


# aws
export AWS_PROFILE=pranav

alias pi="ssh prnvbn@prnvbn-pi.local"
