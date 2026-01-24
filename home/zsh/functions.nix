# zsh カスタム関数定義
{ ... }:

{
  programs.zsh.initContent = ''
    # fzf カスタム関数
    fbr() {
      local branches branch
      branches=$(git branch --all | grep -v HEAD) &&
      branch=$(echo "$branches" |
               fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
      git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }

    fcat() {
      find * -type f | fzf --layout=reverse --preview "bat --color=always {}"
    }

    fv() {
      local files
      files=$(fzf-tmux -d 40% --multi --preview-window=right:70% \
        --preview 'bat --color=always --style=header,grid --line-range :500 {}') &&
      nvim $files
    }

    # brewfile管理
    brewfile-dump() {
      brew bundle dump --force --global
      if [ -f ~/.Brewfile ]; then
        cp ~/.Brewfile ~/dotfiles/brew/Brewfile
      else
        echo "Error: ~/.Brewfile not found"
      fi
    }
  '';
}
