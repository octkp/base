.PHONY: switch update clean check fmt

# ユーザー名を自動取得
USERNAME := $(shell whoami)

# 設定を適用
switch:
	home-manager switch --flake .#$(USERNAME)

# flake.lock を更新して適用
update:
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
