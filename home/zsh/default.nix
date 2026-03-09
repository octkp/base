# zsh メイン設定
{ config, pkgs, lib, ... }:

{
  imports = [
    ./aliases.nix
    ./functions.nix
    ./variables.nix
  ];

  programs.zsh = {
    enable = true;

    # 履歴設定
    history = {
      size = 100000;
      save = 1000000;
      path = "${config.home.homeDirectory}/.zsh_history";
      extended = true;
      ignoreDups = true;
      share = true;
      expireDuplicatesFirst = true;
    };

    # オプション
    autocd = true;

    # compinit のセキュリティチェックを無効化
    completionInit = "autoload -U compinit && compinit -u";

    # 初期化スクリプト
    initContent = lib.mkMerge [
      # メイン初期化
      ''
        # setopt 設定
        setopt auto_pushd
        setopt inc_append_history
        setopt hist_ignore_all_dups
        setopt hist_save_no_dups
        setopt hist_expire_dups_first
        setopt auto_param_slash
        setopt auto_param_keys
        setopt mark_dirs
        setopt auto_menu
        setopt correct
        setopt interactive_comments
        setopt magic_equal_subst
        setopt complete_in_word
        setopt print_eight_bit
        setopt no_beep

        # 補完設定
        autoload -Uz colors; colors
        zstyle ':completion:*:default' menu select=2
        zstyle ':completion:*' matcher-list "" "m:{[:lower:]}={[:upper:]}" "+m:{[:upper:]}={[:lower:]}"
        zstyle ':completion:*' format '%B%F{blue}%d%f%b'
        zstyle ':completion:*' group-name ""
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}

        # 履歴検索
        autoload -Uz history-search-end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end history-search-end
        bindkey "^P" history-beginning-search-backward-end
        bindkey "^N" history-beginning-search-forward-end

        # asdf（Homebrew経由でインストール）
        if [[ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]]; then
          . /opt/homebrew/opt/asdf/libexec/asdf.sh
        fi

        # Go設定
        export GOBIN=$HOME/go/bin
        if command -v asdf &>/dev/null && asdf where golang &>/dev/null 2>&1; then
          export GOROOT=$(asdf where golang)/go
          for version in $(ls ~/.asdf/installs/golang 2>/dev/null); do
            export PATH=$PATH:~/.asdf/installs/golang/$version/go/bin
          done
        fi
        export PATH=$PATH:$HOME/go/bin

        # PostgreSQL@16
        export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

        # Composer
        export PATH=$HOME/.composer/vendor/bin:$PATH

        # カスタムスクリプト読み込み
        [[ -f ~/.config/zsh/secrets.zsh ]] && source ~/.config/zsh/secrets.zsh
        [[ -f ~/.config/zsh/kokopelli_alias.zsh ]] && source ~/.config/zsh/kokopelli_alias.zsh

        # プロンプト前に区切り線を表示
        precmd() {
          print -P "%F{#64748b}''${(r:$COLUMNS::─:)}%f"
        }

        # zeno.zsh 設定
        export ZENO_HOME="$HOME/.config/zeno"
        export ZENO_ENABLE_SOCK=1
        # zeno.zsh キーバインド
        if type zeno > /dev/null 2>&1; then
          bindkey ' ' zeno-auto-snippet
          bindkey '^m' zeno-auto-snippet-and-accept-line
          bindkey '^i' zeno-completion
          bindkey '^g' zeno-ghq-cd
          bindkey '^r' zeno-history-selection
          bindkey '^x^s' zeno-insert-snippet
        fi
      ''
    ];

    # プラグイン
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zeno";
        src = pkgs.fetchFromGitHub {
          owner = "yuki-yano";
          repo = "zeno.zsh";
          rev = "82bb15e6410095883f28d92025a61937fa80aa09";
          sha256 = "sha256-+sDhfZIqQNoDbfA1uNIiS2rl8U6cWtPD4Z14TAec9kw=";
        };
        file = "zeno.zsh";
      }
    ];
  };
}
