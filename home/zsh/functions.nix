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

    # docs/references/repos 内のリポジトリを fzf で選択して移動
    rd() {
      local base_dir="$HOME/ghq/github.com/kokopelli-inc/bigadvance-3.0-docs/references/repos"
      local selected
      selected=$(
        for dir in "$base_dir"/*/; do
          local name=$(basename "$dir")
          local branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "?")
          echo "$name\t($branch)"
        done | column -t -s $'\t' | \
        fzf --preview "eza -la --icons --git $base_dir/{1}" | \
        awk '{print $1}'
      )
      if [ -n "$selected" ]; then
        cd "$base_dir/$selected"
      fi
    }

    # docs/references/repos 内のリポジトリを選択してブランチ切替 + 移動
    rdb() {
      local base_dir="$HOME/ghq/github.com/kokopelli-inc/bigadvance-3.0-docs/references/repos"
      local selected
      selected=$(
        for dir in "$base_dir"/*/; do
          local name=$(basename "$dir")
          local branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "?")
          echo "$name\t($branch)"
        done | column -t -s $'\t' | \
        fzf --preview "eza -la --icons --git $base_dir/{1}" | \
        awk '{print $1}'
      )
      if [ -n "$selected" ]; then
        local repo_dir="$base_dir/$selected"
        local branches branch
        branches=$(git -C "$repo_dir" branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" |
                 fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
        git -C "$repo_dir" checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
        cd "$repo_dir"
      fi
    }

    # Claude Code を起動時にランダムな言語設定で起動
    c() {
      local languages=(
        "お嬢様"
        "5ちゃんねる（専門板）"`
        "体育会系（部活）"
        "RPGの村人"
        "社畜・窓際族"
        "ギャル"
        "武士"
        "厨二病"
        "江戸っ子"
        "薩摩弁"
        "赤ちゃん（バブみ）"
        "ツンデレ"
        "メンヘラ（病み）"`
        "ハードボイルド"
        "実況アナウンサー"
        "昭和の頑固親父"
        "妹"
        "おねショタの姉"
        "幼馴染"
        "ゴーレム（ゴゴ...しか言えない）"
        "狂った犬"
        "先輩に厳しいJK"
      )
      local idx=$(( RANDOM % ''${#languages[@]} ))
      local lang="''${languages[$idx + 1]}"
      local settings="$HOME/.claude/settings.json"

      if [[ -f "$settings" ]]; then
        local tmp=$(jq --arg lang "$lang" '.language = $lang' "$settings")
        echo "$tmp" > "$settings"
      fi

      claude "$@"
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
