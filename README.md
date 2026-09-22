# Ghostty Terminal

macOS Apple Silicon向けの再現可能な Ghostty + zsh 開発環境です。AURORA COCKPITという一貫したUIの上に、履歴検索・補完・project移動・file manager・runtime管理・Git・AI CLI・shell performance計測を統合しています。

## AURORA COCKPIT

- Dark Glass: background `#05070D` / opacity `0.86` / blur `30`
- UDEV Gothic NF 14pt
- Directory + dynamic Git pill
- Node / Dart / Python context
- command duration + failure exit code + current local time
- Floating fzf / fzf-tab UI
- Startup HUD + Engine Metrics
- Quick Terminal / split / prompt navigation / session restore

## Productivity stack

| Area | Tool / feature |
| --- | --- |
| History | Atuin。Ctrl-R、workspace-aware history |
| Navigation | zoxide、AURORA Project Launcher |
| Completion | native zsh completion + Carapace + fzf-tab |
| Files | Yazi、eza、bat、fd、ripgrep |
| Runtime | mise |
| Git | dynamic Git pill、lazygit、delta |
| Benchmark | hyperfine + zprof |
| AI CLI | Codex、Hermes |

詳細は [docs/PRODUCTIVITY.md](docs/PRODUCTIVITY.md) を参照してください。

## Prompt

Starshipは情報を常時出しすぎない構成です。

```text
󰉋 project   main ✓   v24   v3.x  󰔛 2.4s   18:10:15
╰─ ✦ ❯
```

- Node / Dart / Python は対象projectだけ表示
- non-zero exit codeだけRedで表示
- command durationは1.5秒以上だけ表示
- clockは `HH:MM:SS`

## Ghostty behavior

- `window-save-state = always`: window / tab / split状態を復元
- `shell-integration-features = ssh-env,ssh-terminfo`: interactive SSHをGhostty向けに補助
- long-running command終了通知
- typing中はmouse pointerを隠す
- paste protectionとclipboard whitespace cleanup
- working directory / font size inheritance

## Keybindings

| Action | Key |
| --- | --- |
| Split right | Cmd + D |
| Split down | Cmd + Shift + D |
| Move between splits | Cmd + Option + Arrow |
| Resize split | Ctrl + Option + Shift + Arrow |
| Equalize splits | Cmd + Option + 0 |
| Toggle split zoom | Cmd + Shift + Enter |
| Previous prompt | Cmd + Option + K |
| Next prompt | Cmd + Option + J |
| Command Palette | Cmd + Shift + P |
| Quick Terminal | Ctrl + Option + G (global) |

完全版は [docs/KEYBINDINGS.md](docs/KEYBINDINGS.md)。

## Shell commands

```bash
z <keyword>       # zoxide
cdi               # fzf directory picker
lsi               # eza + directory picker

pj                # Git projectを選択してcd
pjc               # projectを選択してCodex
pjg               # projectを選択してLazygit

y                 # Yazi。終了先directoryをshellへ反映

aurora_engine_metrics
aurora_bench
aurora_bench 20

AURORA_ZPROF=1 zsh -i
aurora_zprof
```

Atuinが `Ctrl-R` を担当し、通常のUp Arrowは上書きしません。

## Installation

```bash
git clone https://github.com/asukamiyachi/Ghostty-Terminal.git
cd Ghostty-Terminal
brew bundle --file=Brewfile
```

その後のcopy / symlink方式、Atuin履歴import、validationは [docs/SETUP.md](docs/SETUP.md) を参照してください。

## AURORA Startup / Metrics

ローカルGhosttyのinteractive zshでは、Codex/Hermes状態と現在地を含むStartup HUDを表示します。

```bash
AURORA_STARTUP=0 zsh
AURORA_METRICS=0 zsh
```

Engine MetricsはCPU、Memory、Power、Network、Thermalを起動時に取得します。必要な時だけ `aurora_engine_metrics` で再表示できます。

## Git pill

`git status --porcelain=v2 --branch` を1回だけ実行して描画します。

| State | Example | Color |
| --- | --- | --- |
| Clean | `✓` | Green |
| Dirty | `+2 ●1 ?3` | Gold |
| Ahead | `⇡2` | Cyan |
| Behind | `⇣2` | Gold |
| Diverged | `⇕2/1` | Violet |
| Conflict | `!1` | Red |

## Files

- `ghostty/config.ghostty`: Ghostty UI / session / keybindings / shell integration
- `zsh/.zshrc`: shell integrations
- `zsh/aurora/startup.zsh`: Startup HUD
- `zsh/aurora/engine-metrics.zsh`: Engine Metrics
- `zsh/aurora/git-pill.zsh`: Git pill
- `zsh/aurora/project-launcher.zsh`: `pj` / `pjc` / `pjg`
- `zsh/aurora/benchmark.zsh`: hyperfine / zprof helpers
- `starship/starship.toml`: prompt
- `atuin/config.toml`: history UI
- `git/gitconfig.example`: delta example
- `Brewfile`: dependencies

## Validation

```bash
zsh -n ~/.zshrc
ghostty +validate-config

for cmd in brew git node flutter codex hermes starship zoxide fzf eza bat rg fd lazygit delta jq atuin carapace hyperfine mise yazi; do
  printf '%-12s ' "$cmd"
  command -v "$cmd" || echo 'NOT FOUND'
done
```

Atuin sync、API key、個人Git identityはこのリポジトリから自動設定しません。
