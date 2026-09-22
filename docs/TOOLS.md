# Tools

| Tool | Purpose |
| --- | --- |
| Atuin | 実行時刻・cwd・duration・exit codeを含む履歴DB。Ctrl-Rはworkspace優先検索 |
| zoxide | 履歴ベースのディレクトリ移動。`z <keyword>` |
| fzf | ファイル・ディレクトリ・独自pickerの曖昧検索 |
| fzf-tab | zshのTab補完をfzf UI化 |
| Carapace | CLI引数・サブコマンド補完を追加。生成結果はAURORA cacheへ保存 |
| mise | project単位のruntime・environment・task管理 |
| Yazi | terminal file manager。`y`で終了先directoryへ移動 |
| eza | `ls`の代替。Git状態・アイコン・ツリー表示 |
| bat | シンタックスハイライト付きファイル表示 |
| ripgrep | 高速全文検索。コマンドは`rg` |
| fd | 高速ファイル検索。Project Launcherのrepo探索にも使用 |
| lazygit | Git操作用TUI |
| delta | Git diffを読みやすくするpager |
| hyperfine | `aurora_bench`でzsh startupを比較計測 |
| jq | JSONの検索・整形・抽出 |
| Starship | Git・runtime・exit status・duration・current timeを表示 |
| `zsh/aurora/startup.zsh` | Ghostty限定の軽量AURORA起動HUD |
| `zsh/aurora/git-pill.zsh` | 1回のGit statusから状態を描画するHUD |
| `zsh/aurora/engine-metrics.zsh` | CPU・Memory・Power・Network・Thermalの起動時HUD |
| `zsh/aurora/project-launcher.zsh` | `pj` / `pjc` / `pjg` |
| `zsh/aurora/benchmark.zsh` | `aurora_bench` / `aurora_zprof` |
| Codex | ターミナルで利用するコーディングエージェントCLI |
| Hermes | 現在のMacで利用するエージェントCLI |

## Ownership of interactive keys

- `Ctrl-R`: Atuin
- Tab: zsh completion → Carapace completers → fzf-tab UI
- fzf: custom pickers、Ctrl-T等に継続利用
- Up Arrow: Atuinでは上書きせず通常のzsh挙動を維持

Atuin syncはこのリポジトリから有効化しません。
