{ config, pkgs, ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    defaultOptions = [
      "--height 40%"
      "--reverse"
      "--border"
    ];

    # Ctrl+T でファイル検索
    fileWidgetOptions = [
      "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    ];

    # Ctrl+R で履歴検索
    historyWidgetOptions = [
      "--sort"
      "--exact"
    ];
  };
}
