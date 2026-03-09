{ config, pkgs, lib, username, repoDir, ... }:

{
  imports = [
    ./packages.nix
    ./zsh
    ./git.nix
    ./programs/fzf.nix
    ./programs/bat.nix
    ./programs/starship.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";

    # 環境変数
    sessionVariables = {
      LANG = "ja_JP.UTF-8";
      EDITOR = "nvim";
    };

    # PATH追加
    sessionPath = [
      "$HOME/.local/bin"
    ];
  };

  # ファイルのシンボリックリンク（すべて mkOutOfStoreSymlink で管理）
  home.file = {
    # Zed設定
    ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zed/settings.json";
    ".config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zed/keymap.json";
    ".config/zed/tasks.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zed/tasks.json";

    # Claude設定
    ".claude".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/claude";

    # カスタムzshスクリプト（会社固有など）
    ".config/zsh/kokopelli_alias.zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zsh/kokopelli_alias.zsh";

    # zeno.zsh設定
    ".config/zeno/config.ts".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zeno/config.ts";

    # Ghostty設定
    ".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/ghostty/config";

    # pgcli設定
    ".config/pgcli/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/pgcli/config";

    # gwq設定
    ".config/gwq/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/gwq/config.toml";

    # Hammerspoon設定
    ".hammerspoon".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/hammerspoon";

    # Neovim設定
    ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/nvim";

    # 便利なエイリアスへのシンボリックリンク
    "kalias".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/${repoDir}/dotfiles/zsh/kokopelli_alias.zsh";
  };

  # home-manager 自身を管理
  programs.home-manager.enable = true;
}
