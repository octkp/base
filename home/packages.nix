{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # CLI ツール
    act                 # GitHub Actions ローカル実行
    awscli2             # AWS CLI
    bat                 # cat の改良版
    colordiff           # diff の色付け
    curl
    deno
    eza                 # ls の改良版（旧 exa）
    fd                  # find の改良版
    fzf                 # ファジーファインダー
    gh                  # GitHub CLI
    ghq                 # リポジトリ管理
    git
    jq                  # JSON プロセッサ
    neovim
    ripgrep             # grep の改良版
    tmux
    tree

    # Node.js エコシステム
    nodejs_20
    nodePackages.eslint
    bun

    # 開発ツール
    go
    python311

    # フォント（新しいnixpkgsではnerd-fontsに変更）
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
