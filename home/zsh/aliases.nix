# zsh エイリアス定義
{ ... }:

{
  programs.zsh.shellAliases = {
    # Git（zenoと重複しないもののみ）
    g = "lazygit";
    ga = "git add";
    gb = "git branch";
    gl = "git log";
    gr = "git reset";
    gbd = "git branch --merged main | grep -vE '^\\*|main$' | xargs -I % git branch -d %";
    glg = "git log --oneline --graph --decorate";
    gcm = "git commit";

    # ツール
    diff = "colordiff";
    ls = "eza -la --icons";
    lt = "eza --icons --git --time-style relative -al";

    # zsh設定
    load = "exec zsh";

    # Claude
    c = "claude";

    # その他
    repo = "cd ~/ghq/github.com";

    # home-manager
    hm-switch = "home-manager switch --flake ~/dotfiles";
  };
}
