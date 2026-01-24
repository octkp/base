if [ ! -e "$HOME/.config/zsh" ]; then
  ln -fs "$HOME/dotfiles/zsh/" "$HOME/.config/zsh"
fi

if [ ! -e "$HOME/.zshrc" ]; then
  ln -fs "$HOME/dotfiles/zshrc" "$HOME/.zshrc"
fi

if [ ! -e "$HOME/zalias" ]; then
  ln -fs "$HOME/dotfiles/zsh/alias.zsh" "$HOME/zalias"
fi

if [ ! -e "$HOME/kalias" ]; then
  ln -fs "$HOME/dotfiles/zsh/kokopelli_alias.zsh" "$HOME/kalias"
fi

if [ ! -e "$HOME/.config/git" ]; then
  ln -fs "$HOME/dotfiles/git/" "$HOME/.config/git"
fi

if [ ! -e "$HOME/.claude" ]; then
  ln -fs "$HOME/dotfiles/claude/" "$HOME/.claude"
fi

if [ ! -e "$HOME/.Brewfile" ]; then
  cp "$HOME/dotfiles/brew/Brewfile" "$HOME/Brewfile"
fi
