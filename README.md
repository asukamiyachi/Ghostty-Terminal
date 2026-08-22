# Ghostty Terminal

macOS / Ghostty / zsh を中心にした、日常開発用ターミナル環境の構成メモです。

## Current status

2026-08-22 時点で、ターミナル環境は正常に動作しています。

### zsh

- `zsh -n ~/.zshrc`: 成功
- 新しい zsh の起動: 成功
- `zoxide`: 読み込み成功
- `compinit`: 読み込み成功
- `fzf-tab`: 読み込み成功
- Tab キー: `fzf-tab-complete`
- `cdi` / `lsi`: 利用可能
- 読み込み順: autosuggestions → Starship → syntax highlighting
- syntax highlighting は最後に読み込み

### Ghostty

- `ghostty +validate-config`: 成功
- 背景透過: `0.80`
- 背景ぼかし: `16`
- zsh shell integration: 有効
- コマンド終了通知: 有効
- Command Palette: `Cmd + Shift + P`
- フォント拡大縮小キー: 設定済み
- Split 操作: 設定済み
- Quick Terminal: 設定済み

### CLI / TUI

以下はすべて利用可能です。

- Homebrew (`brew`)
- Git (`git`)
- Node.js (`node`)
- Flutter (`flutter`)
- Codex (`codex`)
- Hermes (`hermes`)
- Starship (`starship`)
- zoxide (`zoxide`)
- fzf (`fzf`)
- eza (`eza`)
- bat (`bat`)
- ripgrep (`rg`)
- fd (`fd`)
- lazygit (`lazygit`)
- delta (`delta`)
- jq (`jq`)

`fzf-tab` は実行ファイルではなく zsh プラグインです。そのため `command -v fzf-tab` で見つからないのは正常です。Homebrew の `fzf-tab 1.3.0` を使用しています。

### Git + delta

```ini
core.pager = delta
interactive.diffFilter = delta --color-only
delta.navigate = true
delta.side-by-side = false
delta.line-numbers = true
```

## Useful commands

### Directory navigation

```bash
z <keyword>
```

例:

```bash
z AI-Hack
```

### Interactive directory selection

```bash
cdi
```

### Interactive listing

```bash
lsi
```

`lsi` では一覧を確認しながら矢印キーでディレクトリを選択できます。

### File / code tools

```bash
eza --icons
bat <file>
rg <query>
fd <name>
lazygit
```

## Shell architecture

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

## Notes

背景透過 `0.80` は見た目を優先した強めの設定です。コードやログの可読性を優先する場合は `0.85〜0.90` が候補です。

## Not committed yet

現時点では、ローカルの実ファイルを推測して GitHub に書き込むことは避けています。今後、ローカルの最新版を取得してから以下を追加する想定です。

- `~/.zshrc`
- `~/.config/ghostty/config.ghostty`
- `~/.config/starship.toml`
- 必要に応じて Hammerspoon のターミナル関連設定
- 再現用の `Brewfile`
