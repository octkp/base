# カレントディレクトリのファイルとディレクトリを fzf で選択
select_file_or_dir() {
    (echo ".."; echo "@"; fd -t f -t d --exclude '.*') | fzf --preview="[[ -d {} ]] && ls -la {} || bat --style=numbers --color=always {}" --preview-window=right:50%
}

# メイン処理
current_dir=$(pwd)  # 初期カレントディレクトリを保持
while true; do
    selection=$(select_file_or_dir)

    # 選択がキャンセルされた場合、ループを終了
    if [[ -z "$selection" ]]; then
        break
    fi

    # '..'が選択された場合、親ディレクトリに移動
    if [[ "$selection" == ".." ]]; then
        cd ..
        current_dir=$(pwd)  # カレントディレクトリを更新
        continue
    fi

    # '@'が選択された場合、その時点のカレントディレクトリに移動して終了
    if [[ "$selection" == "@" ]]; then
        echo "$current_dir";
        cd "$current_dir"  # 最後に選択したディレクトリに移動
        break
    fi

    # ディレクトリの場合、その中に移動
    if [[ -d "$selection" ]]; then
        cd "$selection"
        current_dir=$(pwd)  # カレントディレクトリを更新
    # ファイルの場合、エディタで開く（例: vim）
    elif [[ -f "$selection" ]]; then
        nvim "$selection"
        break
    fi
done
