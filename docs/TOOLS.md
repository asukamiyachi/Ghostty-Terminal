# Tools

| Tool | Purpose |
| --- | --- |
| zoxide | 履歴ベースのディレクトリ移動。`z <keyword>` |
| fzf | 曖昧検索、Ctrl-R履歴検索、ファイル選択 |
| fzf-tab | zshのTab補完をfzf UI化 |
| eza | `ls`の代替。Git状態・アイコン・ツリー表示 |
| bat | シンタックスハイライト付きファイル表示 |
| ripgrep | 高速全文検索。コマンドは`rg` |
| fd | 高速ファイル検索 |
| lazygit | Git操作用TUI |
| delta | Git diffを読みやすくするpager |
| jq | JSONの検索・整形・抽出 |
| Starship | Git・Node等を表示するプロンプト |
| `zsh/aurora/startup.zsh` | Ghosttyだけで表示する軽量AURORA起動HUD。`AURORA_STARTUP=0`で無効化可能 |
| `zsh/aurora/git-pill.zsh` | `git status --porcelain=v2 --branch`を1回だけ実行し、Starship用のGit状態Pillを出力 |
| `zsh/aurora/engine-metrics.zsh` | macOS標準コマンドからCPU・メモリ・電源・ネットワーク・熱状態を表示するHUD。`aurora_engine_metrics`で手動再表示可能 |
| Codex | ターミナルで利用するコーディングエージェントCLI |
| Hermes | 現在のMacで利用するエージェントCLI |

`fzf-tab`は実行ファイルではありません。Homebrewのプラグインファイルをzshからsourceするため、`command -v fzf-tab`で表示されないのは正常です。
