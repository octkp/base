# zsh エイリアス定義
{ ... }:

{
  programs.zsh.shellAliases = {
    # Git（zenoと重複しないもののみ）
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

    # Docker（zenoと重複しないもののみ）
    d = "docker";
    horobi = "docker compose down --rmi all --volumes --remove-orphans";
    dcr = "docker compose rm -fsv";

    # zsh設定
    zsh = "nvim ~/.zshrc";
    load = "exec zsh";
    zalias = "nvim ~/zalias";

    # Claude
    c = "claude";

    # Brewfile
    brewfile-cleanup = "brew bundle cleanup --force --global";
    brewfile-install = "brew bundle --global";
    update-app = "brew update && brew upgrade";

    # その他
    drive = "cd ~/Library/CloudStorage/GoogleDrive-octkmr@gmail.com/マイドライブ/";
    script = ''open -na "PhpStorm.app" --args ~/scripts'';
    dot = ''open -na "PhpStorm.app" --args ~/dotfiles'';
    edit = ''open -na "PhpStorm.app" --args .'';
    "edit-gl" = ''open -na "GoLand.app" --args .'';
    cs = "cursor .";
    phpunit = "vendor/bin/phpunit --testdox --colors";
    phpfix = "vendor/bin/php-cs-fixer";
    note = ''open -na "PhpStorm.app" --args ~/notes'';
    f = "source ~/.config/zsh/f.zsh";

    # home-manager
    hm-switch = "home-manager switch --flake ~/dotfiles";
  };
}
