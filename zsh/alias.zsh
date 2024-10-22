# git
alias ga="git add"
alias gd="git diff"
alias gb="git branch"
alias gs="git status"
alias gl="git log"
alias gr="git reset"
alias gbd="git branch --merged main | grep -vE '^\*|main$' | xargs -I % git branch -d %"
alias glg="git log --oneline --graph --decorate"
alias gps="git push"
alias gpl="git pull"
alias gcm="git commit"
alias gco="git checkout"
alias gst="git stash"

git-commit-rename() {
  git commit --amend -m "$1"
}

# neovim
alias v="nvim"

# colordiff
if [[ $(command -v colordiff) ]]; then
  alias diff='colordiff'
fi

# exa
if [[ $(command -v eza) ]]; then
  alias ls='eza -la --icons'
  alias lt='eza --icons --git --time-style relative -al'
fi

# docker
alias d="docker"
alias dc="docker compose"
alias horobi="docker compose down --rmi all --volumes --remove-orphans"
alias dcr="docker compose rm -fsv"

# sail
# alias sail="bash sail"
alias sail="vendor/bin/sail"

# zsh
alias zsh="nvim ~/.zshrc"
alias load="source ~/.zshrc"
alias zalias="nvim ~/zalias"

# cloude code
alias cc="claude"

# brewfile
# 現在インストールされているHomebrewのパッケージを Brewfile にエクスポートします。これにより、後で同じパッケージを再インストールするのが簡単になります。
brewfile-dump() {
	brew bundle dump --force --global
	if [ -f ~/.Brewfile ]; then
		cp ~/.Brewfile ~/dotfiles/brew/Brewfile
	else
		echo "Error: ~/.Brewfile not found"
	fi
}

# Brewfile に含まれていないパッケージを削除します。インストール済みの不要なパッケージの整理に役立ちます。
alias brewfile-cleanup="brew bundle cleanup --force --global"
# グローバルな Brewfile を元に必要なパッケージをインストールします。環境の再構築などに便利ですね。
alias brewfile-install="brew bundle --global"
# Homebrewのパッケージとリポジトリを更新・アップグレードします。最新バージョンのツールを使いたいときに有用です。
alias update-app="brew update && brew upgrade"

# googledrive
alias drive="cd ~/Library/CloudStorage/GoogleDrive-octkmr@gmail.com/マイドライブ/"

#phpstorm
alias script="open -na \"PhpStorm.app\" --args ~/scripts"
alias dot="open -na \"PhpStorm.app\" --args ~/dotfiles"
alias edit="open -na \"PhpStorm.app\" --args ."

#goland
alias edit-gl="open -na \"GoLand.app\" --args ."

# cursor
alias cs="cursor ."

#phpunit
alias phpunit="vendor/bin/phpunit --testdox --colors"

#php-cs-fixer
alias phpfix="vendor/bin/php-cs-fixer"

# fzf
alias f="source ~/.config/zsh/f.zsh"

alias note="open -na \"PhpStorm.app\" --args ~/notes"
