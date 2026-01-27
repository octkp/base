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

    # ghq + gwq + fzf でリポジトリ/worktree を選択して移動
    r() {
      local selected
      selected=$(
        { ghq list --full-path; gwq list --full-path 2>/dev/null; } | sort -u | \
        fzf --preview 'eza -la --icons --git {}'
      )
      if [ -n "$selected" ]; then
        cd "$selected"
      fi
    }

    # ghq + gwq + fzf + claudeでリポジトリ/worktree を選択して移動
    r() {
      local selected
      selected=$(
        { ghq list --full-path; gwq list --full-path 2>/dev/null; } | sort -u | \
        fzf --preview 'eza -la --icons --git {}'
      )
      if [ -n "$selected" ]; then
        cd "$selected"
      fi
    }

    # gwq でworktreeを作成
    wt-add() {
      if [ -z "$1" ]; then
        echo "Usage: wt-add <branch-name>"
        return 1
      fi

      # -b をつけることで、新規ブランチとして作成する
      # -s をつけることで、自動的にそのディレクトリに移動（cd）する
      gwq add -b "$1" -s
    }

    # gwq でworktreeを削除（fzfで選択）
    wt-rm() {
      local selected
      # --full-path は外して、標準のリスト（リポジトリ=ブランチ形式）を使う
      selected=$(gwq list 2>/dev/null | fzf --prompt="Delete worktree > ")

      if [ -n "$selected" ]; then
        # selected には "owner/repo=branch" が入るので、そのまま remove に渡せる
        gwq remove "$selected"
      fi
    }

    # インタラクティブファイルナビゲーター
    f() {
      local current_dir selection
      current_dir=$(pwd)

      while true; do
        selection=$( (echo ".."; echo "@"; fd -t f -t d --exclude '.*') | \
          fzf --preview="[[ -d {} ]] && ls -la {} || bat --style=numbers --color=always {}" \
              --preview-window=right:50% )

        [[ -z "$selection" ]] && break

        if [[ "$selection" == ".." ]]; then
          cd ..
          current_dir=$(pwd)
        elif [[ "$selection" == "@" ]]; then
          cd "$current_dir"
          break
        elif [[ -d "$selection" ]]; then
          cd "$selection"
          current_dir=$(pwd)
        elif [[ -f "$selection" ]]; then
          nvim "$selection"
          break
        fi
      done
    }
  '';
}
