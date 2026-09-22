# Setup

この手順は新しいApple Silicon Macを想定します。既存設定を上書きする前に、必ずバックアップを作成してください。

## 1. Homebrewとリポジトリ

Homebrewを公式手順で導入し、リポジトリをcloneします。

```bash
git clone https://github.com/asukamiyachi/Ghostty-Terminal.git
cd Ghostty-Terminal
brew bundle --file=Brewfile
```

`Brewfile`には現在の再現に必要なformula/caskだけを記録しています。Flutter、Ghostty、UDEV Gothic NF、Codexはcaskとして記録しています。

## 2. 設定のバックアップ

```bash
backup="$HOME/.dotfiles-backups/ghostty-terminal-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for f in "$HOME/.zshrc" "$HOME/.zprofile" "$HOME/.gitconfig"; do
  [ -f "$f" ] && cp "$f" "$backup/"
done
[ -f "$HOME/.config/ghostty/config.ghostty" ] && cp "$HOME/.config/ghostty/config.ghostty" "$backup/"
[ -f "$HOME/.config/starship.toml" ] && cp "$HOME/.config/starship.toml" "$backup/"
```

## 3. 設定を配置

```bash
mkdir -p "$HOME/.config/ghostty" "$HOME/.config/aurora"
cp ghostty/config.ghostty "$HOME/.config/ghostty/config.ghostty"
cp zsh/.zshrc "$HOME/.zshrc"
cp zsh/.zprofile "$HOME/.zprofile"
cp zsh/aurora/*.zsh "$HOME/.config/aurora/"
cp starship/starship.toml "$HOME/.config/starship.toml"
```

Gitの個人名・メールは環境固有なので、`git/gitconfig.example`を確認して必要なdelta設定だけ手動で追加してください。Hammerspoonの`terminal.capture.lua`は、既存の`common.key_sequence`モジュールがある環境でのみ配置してください。

## 4. Symlink方式（任意）

バックアップ後にだけ使用します。

```bash
mkdir -p "$HOME/.config/aurora"
ln -sfn "$PWD/ghostty/config.ghostty" "$HOME/.config/ghostty/config.ghostty"
ln -sfn "$PWD/zsh/.zshrc" "$HOME/.zshrc"
ln -sfn "$PWD/zsh/.zprofile" "$HOME/.zprofile"
for f in "$PWD"/zsh/aurora/*.zsh; do
  ln -sfn "$f" "$HOME/.config/aurora/$(basename "$f")"
done
ln -sfn "$PWD/starship/starship.toml" "$HOME/.config/starship.toml"
```

## 5. Hermes

Hermesは現在のMacでは `$HOME/.local/bin/hermes` にあり、Brewfileでは管理していません。別途、利用するHermesの公式手順で導入し、次を確認します。

```bash
command -v hermes
```

## 6. Validation

```bash
zsh -n "$HOME/.zshrc"
ghostty +validate-config
for cmd in brew git node flutter codex hermes starship zoxide fzf eza bat rg fd lazygit delta jq; do
  printf '%-12s ' "$cmd"
  command -v "$cmd" || echo 'NOT FOUND'
done
```
