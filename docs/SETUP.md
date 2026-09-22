# Setup

この手順は新しいApple Silicon Macを想定します。既存設定を上書きする前に、必ずバックアップを作成してください。

## 1. Homebrewとリポジトリ

Homebrewを公式手順で導入し、リポジトリをcloneします。

```bash
git clone https://github.com/asukamiyachi/Ghostty-Terminal.git
cd Ghostty-Terminal
brew bundle --file=Brewfile
```

主要な追加CLIは Atuin、Carapace、hyperfine、mise、Yazi です。

## 2. 設定のバックアップ

```bash
backup="$HOME/.dotfiles-backups/ghostty-terminal-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for f in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.gitconfig"; do
  [ -f "$f" ] && cp "$f" "$backup/"
done
[ -f "$HOME/.config/ghostty/config.ghostty" ] && cp "$HOME/.config/ghostty/config.ghostty" "$backup/"
[ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$backup/"
[ -f "$HOME/.config/atuin/config.toml" ] && cp "$HOME/.config/atuin/config.toml" "$backup/atuin-config.toml"
```

## 3. 設定を配置

```bash
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/aurora" "$HOME/.config/atuin"
cp ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
cp zsh/.zshrc "$HOME/.zshrc"
cp zsh/.zprofile "$HOME/.zprofile"
cp zsh/aurora/*.zsh "$HOME/.config/aurora/"
cp starship/starship.toml "$HOME/.config/starship.toml"
cp atuin/config.toml "$HOME/.config/atuin/config.toml"
```

Gitの個人名・メールは環境固有なので、`git/gitconfig.example`を確認して必要なdelta設定だけ手動で追加してください。

## 4. Symlink方式（任意）

バックアップ後にだけ使用します。

```bash
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/aurora" "$HOME/.config/atuin"
ln -sfn "$PWD/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/zsh/.zprofile" "$HOME/.zprofile"
for f in "$PWD"/zsh/aurora/*.zsh; do
  ln -sfn "$f" "$HOME/.config/aurora/$(basename "$f")"
done
ln -sfn "$PWD/starship/starship.toml" "$HOME/.config/starship.toml"
ln -sfn "$PWD/atuin/config.toml" "$HOME/.config/atuin/config.toml"
```

## 5. Atuin history migration（任意）

Atuinは設定しただけでは既存のzsh履歴を消しません。過去履歴もAtuinへ取り込みたい場合だけ実行します。

```bash
atuin import zsh
```

このリポジトリはAtuinのアカウント作成やsyncを自動設定しません。syncを明示的に設定しない限り、履歴DBはローカル利用を前提にします。

## 6. Project Launcher

既定では次を最大6階層探索します。

- `~/Documents`
- `~/Developer`
- `~/Projects`

別の場所も対象にしたい場合は、colon区切りで上書きできます。

```bash
export AURORA_PROJECT_ROOTS="$HOME/Documents:$HOME/src:$HOME/work"
```

コマンド:

```bash
pj    # projectを選択してcd
pjc   # projectを選択してCodex
pjg   # projectを選択してLazygit
```

## 7. Shell performance

通常ベンチマーク:

```bash
aurora_bench
aurora_bench 20
```

詳細な関数別profiling:

```bash
AURORA_ZPROF=1 zsh -i
aurora_zprof
```

`aurora_bench`は通常起動と、Startup HUD / Engine Metricsを無効化したcore shellを比較します。

## 8. Hermes

Hermesは現在のMacでは `$HOME/.local/bin/hermes` にあり、Brewfileでは管理していません。別途、利用するHermesの公式手順で導入します。

```bash
command -v hermes
```

## 9. Validation

```bash
zsh -n "$HOME/.zshrc"
ghostty +validate-config

for cmd in brew git node flutter codex hermes starship zoxide fzf eza bat rg fd lazygit delta jq atuin carapace hyperfine mise yazi; do
  printf '%-12s ' "$cmd"
  command -v "$cmd" || echo 'NOT FOUND'
done
```

Starship設定の読み込み確認:

```bash
STARSHIP_CONFIG="$HOME/.config/starship.toml" starship config
```
