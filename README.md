# Ghostty Terminal

再現可能な macOS Apple Silicon 向けの Ghostty + zsh 開発ターミナル環境です。Codex、Hermes、Git、Node.js、Flutterを日常的に使うための設定を、現在正常動作しているMacから記録しています。

## Overview

このリポジトリは設定のバックアップと再構築手順を提供します。設定を自動で上書きするインストーラーではありません。導入前に必ず既存dotfilesをバックアップしてください。

## Design — AURORA COCKPIT

Dark Glassを土台に、Electric Cyanを現在地と操作、Neon VioletをGit/AI、Greenを成功、Goldを時間・注意、Redを異常へ割り当てたSF AI開発コンソールのUIです。

- Void Black + 透明度`0.86` + blur`30`による可読性重視のDark Glass
- UDEV Gothic NF 14ptと、選択的なBoldによるNerd Font HUD
- DirectoryだけをPowerline pillにした、情報過多にしないStarship
- Cyan border、Violet選択、Pink highlightのFloating fzf/fzf-tab
- semantic syntax colorsと、AURORA用delta設定例

Rainbowは常時使わず、Cyan → Blue → Violet → Pinkを選択状態などの小さなアクセントに限定しています。

## AURORA Startup

新しいローカルGhosttyの対話シェルでは、巨大なASCIIアートではなく、Codex/Hermesの利用可否と現在地を含む小さな起動HUDを表示します。`GHOSTTY_RESOURCES_DIR`を検出に使用するため、SSH、CI、非対話シェルでは表示しません。

一時的に非表示にするには、次のように起動します。

```bash
AURORA_STARTUP=0 zsh
```

毎回非表示にする場合は、`.zprofile`など、`.zshrc`より先に読み込む個人設定へ`export AURORA_STARTUP=0`を追加してください。起動時の確認は`command -v codex`と`command -v hermes`だけで、バージョン取得やネットワークアクセスは行いません。

## Dynamic Git Pill

Starshipの標準Gitモジュール2つを重ねず、1つのPowerline型HUD Pillへ統合しています。補助スクリプトは`git status --porcelain=v2 --branch`を1回だけ実行して状態を決めるため、リポジトリ外には表示されません。

| State | 表示例 | Color |
| --- | --- | --- |
| Clean | `✓` | Green `#8FF0A4` |
| Dirty | `+2 ●1 ?3` | Gold `#FFD166` |
| Ahead | `⇡2` | Cyan `#59E1FF` |
| Behind | `⇣2` | Gold `#FFD166` |
| Diverged | `⇕2/1` | Violet `#BE8CFF` |
| Conflict | `!1` | Red `#FF6384` |

## AURORA ENGINE METRICS

Startup HUDの下へ、macOS標準コマンドだけで取得する実システム情報を表示します。CPU使用率、使用メモリ、バッテリー残量と電源状態、到達可能なネットワークインターフェース、熱状態を1回だけ取得します。

| Card | 実データ | Note |
| --- | --- | --- |
| CPU | 全プロセスCPU使用率をコア数で正規化 | `ps` / `sysctl` |
| Memory | active + wired + compressed memory | `vm_stat` / `sysctl` |
| Power | バッテリー残量・充電状態 | `pmset -g batt` |
| Network | 到達可能なインターフェース | `scutil --nwi` |
| Thermal | 熱警告状態とバッテリー温度 | `pmset -g therm` / `ioreg` |

Apple SiliconではCPU温度の標準取得には管理者権限が必要な場合があるため、CPU温度を推測表示しません。代わりにmacOSが報告する熱状態と、取得可能な実バッテリー温度を表示します。

`AURORA_METRICS=0 zsh`で起動時のMetricsだけを無効化できます。読み込み後は`aurora_engine_metrics`で任意の時点に再表示できます。

## Screenshot

スクリーンショットは現在コミットしていません。

## Stack

Ghostty、zsh、Starship、zoxide、compinit、fzf、fzf-tab、zsh-autosuggestions、zsh-syntax-highlighting、eza、bat、ripgrep、fd、jq、lazygit、git-delta、Codex、Hermes。

## Architecture

```text
Ghostty
└── zsh
    ├── zoxide
    ├── compinit
    ├── fzf / fzf-tab
    ├── autosuggestions
    ├── Starship
    └── syntax highlighting

CLI / TUI
├── eza / bat / rg / fd / jq
├── lazygit / delta
├── Codex
└── Hermes
```

## Installation

詳細手順は [docs/SETUP.md](docs/SETUP.md) を参照してください。

```bash
git clone https://github.com/asukamiyachi/Ghostty-Terminal.git
cd Ghostty-Terminal
brew bundle --file=Brewfile
```

Ghostty、UDEV Gothic NF、Homebrew CLIを導入した後、バックアップを作成して設定を配置します。Symlink方式も利用できますが、既存ファイルを先に退避してください。

## Keybindings

実際の `ghostty/config.ghostty` から抽出した一覧は [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md) にあります。

| Action | Key |
| --- | --- |
| Split right | Cmd + D |
| Split down | Cmd + Shift + D |
| Move between splits | Cmd + Option + Arrow |
| Toggle split zoom | Cmd + Shift + Enter |
| Command Palette | Cmd + Shift + P |
| Increase font size | Cmd + = |
| Decrease font size | Cmd + - |
| Reset font size | Cmd + 0 |
| Quick Terminal | Ctrl + Option + G (global) |

## Shell commands

```bash
z <keyword>       # 履歴ベースのディレクトリ移動
cdi               # fzfでディレクトリを選択して移動
lsi               # eza一覧の後に矢印キーでディレクトリ選択
eza --icons=auto
bat <file>
rg <query>
fd <name>
lazygit
git diff           # delta pager
codex
hermes
```

`eza 0.23.5`では `--icons` 単体ではなく `--icons=auto` を使用します。

## Optional delta theme

`git/gitconfig.example`にはAURORA用のdelta色設定を含めています。個人名・メールを含む既存の`~/.gitconfig`を置換せず、必要なセクションだけ手動で追加してください。

## Codex / Hermes

以下のコマンドが利用可能であることを前提にしています。認証情報やAPIキーはこのリポジトリに保存しません。

```bash
codex
hermes
```

HermesはHomebrew管理ではなく、現在のMacでは `$HOME/.local/bin/hermes` にあります。インストール方法はこのリポジトリでは固定していません。

## Validation

```bash
zsh -n ~/.zshrc
ghostty +validate-config

for cmd in brew git node flutter codex hermes starship zoxide fzf eza bat rg fd lazygit delta jq; do
  printf '%-12s ' "$cmd"
  command -v "$cmd" || echo 'NOT FOUND'
done
```

## Files

- `ghostty/config.ghostty`: 実際に使用中のGhostty設定
- `zsh/.zshrc`, `zsh/.zprofile`: 実際に使用中のzsh設定
- `zsh/aurora/startup.zsh`: Ghostty限定の軽量起動HUD
- `zsh/aurora/git-pill.zsh`: 1回のGit statusから状態を描画するStarship用HUD
- `zsh/aurora/engine-metrics.zsh`: macOS実システム情報を表示するENGINE METRICS HUD
- `starship/starship.toml`: 実際に使用中のStarship設定
- `git/gitconfig.example`: 個人情報を除いたdelta設定例
- `hammerspoon/terminal.capture.lua`: Ghostty/Terminal用のターミナルキャプチャ部分。既存の`common.key_sequence`モジュールを前提とします
- `Brewfile`: 現在の再現に必要なHomebrew formula/cask

ライセンスは既存指定がないため、このリポジトリでは未指定です。
