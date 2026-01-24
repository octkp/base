import { defineConfig } from "@yuki-yano/zeno";

export default defineConfig(() => ({
  // スニペット設定
  snippets: [
    // Git
    {
      name: "git status",
      keyword: "gs",
      snippet: "git status",
    },
    {
      name: "git add all",
      keyword: "ga.",
      snippet: "git add .",
    },
    {
      name: "git commit",
      keyword: "gc",
      snippet: "git commit -m '{{commit_message}}'",
    },
    {
      name: "git push",
      keyword: "gps",
      snippet: "git push",
    },
    {
      name: "git pull",
      keyword: "gpl",
      snippet: "git pull",
    },
    {
      name: "git checkout",
      keyword: "gco",
      snippet: "git checkout ",
    },
    {
      name: "git branch",
      keyword: "gbr",
      snippet: "git branch",
    },
    {
      name: "git log oneline",
      keyword: "glo",
      snippet: "git log --oneline -20",
    },
    {
      name: "git diff",
      keyword: "gd",
      snippet: "git diff",
    },
    {
      name: "git stash",
      keyword: "gst",
      snippet: "git stash",
    },

    // Docker
    {
      name: "docker compose",
      keyword: "dc",
      snippet: "docker compose ",
    },
    {
      name: "docker compose up",
      keyword: "dcu",
      snippet: "docker compose up -d",
    },
    {
      name: "docker compose down",
      keyword: "dcd",
      snippet: "docker compose down",
    },
    {
      name: "docker compose logs",
      keyword: "dcl",
      snippet: "docker compose logs -f",
    },
    {
      name: "docker ps",
      keyword: "dps",
      snippet: "docker ps",
    },
    {
      name: "docker compose exec",
      keyword: "dce",
      snippet: "docker compose exec ",
    },

    // ディレクトリ移動
    {
      name: "go back",
      keyword: "..",
      snippet: "cd ..",
    },
    {
      name: "go back 2",
      keyword: "...",
      snippet: "cd ../..",
    },

    // home-manager
    {
      name: "home-manager switch",
      keyword: "hms",
      snippet: "home-manager switch --flake ~/dotfiles",
    },

    // Claude
    {
      name: "claude",
      keyword: "cl",
      snippet: "claude ",
    },
  ],

  // 略語展開設定
  abbrs: [
    {
      name: "git",
      abbr: "g",
      action: "git",
    },
    {
      name: "docker",
      abbr: "d",
      action: "docker",
    },
    {
      name: "kubectl",
      abbr: "k",
      action: "kubectl",
    },
    {
      name: "neovim",
      abbr: "v",
      action: "nvim",
    },
  ],

  // 補完設定
  completions: [
    {
      name: "file",
      patterns: [
        "^cat ",
        "^bat ",
        "^less ",
        "^head ",
        "^tail ",
        "^nvim ",
        "^v ",
      ],
      sourceCommand: "fd --type f --hidden --follow --exclude .git",
      options: {
        "--preview": "bat --color=always --style=numbers {}",
        "--preview-window": "right:50%",
      },
    },
    {
      name: "directory",
      patterns: ["^cd ", "^ls ", "^eza "],
      sourceCommand: "fd --type d --hidden --follow --exclude .git",
      options: {
        "--preview": "eza -la --icons {}",
        "--preview-window": "right:50%",
      },
    },
    {
      name: "git branch",
      patterns: ["^git checkout ", "^git merge ", "^git rebase ", "^gco "],
      sourceCommand: "git branch --all | grep -v HEAD",
      options: {
        "--preview": "git log --oneline -20 {1}",
        "--preview-window": "right:50%",
      },
    },
    {
      name: "docker compose service",
      patterns: [
        "^docker compose exec ",
        "^docker compose logs ",
        "^dce ",
        "^dcl ",
      ],
      sourceCommand: "docker compose config --services 2>/dev/null",
      options: {
        "--preview": "docker compose ps {1} 2>/dev/null",
      },
    },
  ],
}));
