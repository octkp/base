# Language settings
export LANG=ja_JP.UTF-8

# asdf - runtime version manager (initialize before language-specific setup)
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Go
export GOBIN=$HOME/go/bin
export GOROOT=$(asdf where golang)/go
for version in $(ls ~/.asdf/installs/golang); do
    export PATH=$PATH:~/.asdf/installs/golang/$version/go/bin
done
export PATH=$PATH:$HOME/go/bin

# PostgreSQL@12
export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"

# Composer
export PATH=~/.composer/vendor/bin:$PATH

# Windsurf
export PATH="/Users/takano_y/.codeium/windsurf/bin:$PATH"

# Antigravity
export PATH="/Users/takano_y/.antigravity/antigravity/bin:$PATH"

# Local environment setup
. "$HOME/.local/bin/env"
