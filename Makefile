.PHONY: switch update clean check fmt preflight iterm2-save iterm2-apply

# ユーザー名を自動取得
USERNAME := $(shell whoami)

# 事前チェック（dotfiles内ファイルがシンボリックリンクで上書きされる問題を防止）
preflight:
	@if [ -L ~/.config/zsh ]; then \
		echo "エラー: ~/.config/zsh がシンボリックリンクです。"; \
		echo "rm ~/.config/zsh && mkdir -p ~/.config/zsh を実行してください。"; \
		exit 1; \
	fi
	@for f in zsh/kokopelli_alias.zsh zsh/f.zsh; do \
		if [ -L "$(PWD)/$$f" ]; then \
			echo "エラー: $$f がシンボリックリンクになっています。"; \
			echo "git checkout -- $$f で復元してください。"; \
			exit 1; \
		fi; \
	done
	@echo "チェック完了: 問題ありません"

# 設定を適用
switch: preflight
	home-manager switch --flake .#$(USERNAME)

# flake.lock を更新して適用
update: preflight
	nix flake update
	home-manager switch --flake .#$(USERNAME)

# ガベージコレクション
clean:
	nix-collect-garbage -d
	nix store optimise

# 設定をチェック（適用なし）
check:
	nix flake check

# フォーマット
fmt:
	nixfmt *.nix **/*.nix

# 世代一覧
generations:
	home-manager generations

# 初期セットアップ
bootstrap:
	./scripts/bootstrap.sh

# iTerm2設定を保存
iterm2-save:
	@echo "iTerm2の設定を保存しています..."
	plutil -convert xml1 ~/Library/Preferences/com.googlecode.iterm2.plist -o $(PWD)/iterm2/com.googlecode.iterm2.plist
	@echo "保存完了: iterm2/com.googlecode.iterm2.plist"

# iTerm2設定を適用
iterm2-apply:
	@echo "iTerm2の設定を適用しています..."
	@echo "※ iTerm2を閉じてから実行してください"
	cp $(PWD)/iterm2/com.googlecode.iterm2.plist ~/Library/Preferences/
	@echo "適用完了。iTerm2を起動してください。"
