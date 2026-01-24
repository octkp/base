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

if [ ! -e "$HOME/.config/zed/settings.json" ]; then
  ln -fs "$HOME/dotfiles/zed/settings.json" "$HOME/.config/zed/settings.json"
fi

if [ ! -e "$HOME/.config/zed/keymap.json" ]; then
  ln -fs "$HOME/dotfiles/zed/keymap.json" "$HOME/.config/zed/keymap.json"
fi

if [ ! -e "$HOME/.config/zed/tasks.json" ]; then
  ln -fs "$HOME/dotfiles/zed/tasks.json" "$HOME/.config/zed/tasks.json"
fi

if [ ! -e "$HOME/.claude" ]; then
  ln -fs "$HOME/dotfiles/claude/" "$HOME/.claude"
fi

if [ ! -e "$HOME/.Brewfile" ]; then
  cp "$HOME/dotfiles/brew/Brewfile" "$HOME/Brewfile"
fi
