{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    ignores = [
      "**/.claude/settings.local.json"
      ".DS_Store"
      "*.swp"
      ".env.local"
    ];

    # 新しいAPI: settings に統合
    settings = {
      user = {
        name = "octkp";
        email = "takano_y@kokopelli-inc.com";
      };

      color.ui = true;

      core = {
        editor = "vim";
        autocrlf = false;
        ignorecase = false;
        quotepath = false;
      };

      push.default = "current";
      pull.rebase = false;
      init.defaultBranch = "main";

      # GitHub CLI 認証
      credential = {
        "https://github.com" = {
          helper = "!/opt/homebrew/bin/gh auth git-credential";
        };
        "https://gist.github.com" = {
          helper = "!/opt/homebrew/bin/gh auth git-credential";
        };
      };
    };
  };

  # Delta（diff表示改善）- 新しいAPI
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
