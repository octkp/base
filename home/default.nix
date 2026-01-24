{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./packages.nix
    ./zsh
    ./git.nix
    ./programs/fzf.nix
    ./programs/bat.nix
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
  };

  # ファイルのシンボリックリンク（すべて mkOutOfStoreSymlink で管理）
  home.file = {
    # Zed設定
    ".config/zed/settings.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zed/settings.json";
    ".config/zed/keymap.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zed/keymap.json";
    ".config/zed/tasks.json".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zed/tasks.json";

    # Claude設定
    ".claude".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/claude";

    # カスタムzshスクリプト（会社固有など）
    ".config/zsh/kokopelli_alias.zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/kokopelli_alias.zsh";
    ".config/zsh/f.zsh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/f.zsh";

    # zeno.zsh設定
    ".config/zeno/config.ts".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zeno/config.ts";

    # Ghostty設定
    ".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/ghostty/config";

    # 便利なエイリアスへのシンボリックリンク
    "zalias".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/alias.zsh";
    "kalias".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/zsh/kokopelli_alias.zsh";
  };

  # home-manager 自身を管理
  programs.home-manager.enable = true;
}
