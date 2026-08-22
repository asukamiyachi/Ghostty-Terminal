# ==================================================
# Shell environment
# ==================================================

# Keep local tools (Hermes), Homebrew tools, and npm globals available.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.npm-global/bin:$PATH"
typeset -U path PATH

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ==================================================
# Aliases
# ==================================================

alias cx='codex'
# eza 0.23+ requires an explicit icon mode; auto shows icons in Ghostty.
alias ls='eza --icons=auto'
alias ll='eza -lah --icons=auto --git'
alias tree='eza --tree --icons=auto'

# Interactive directory picker. Use `lsi` to list first, then choose with arrows.
cdi() {
  local base="${1:-.}" selected
  selected="$(fd --type d --hidden --exclude .git . "$base" | fzf \
    --height=60% --layout=reverse --border=rounded \
    --border-label=' 󰉋  DIRECTORY ' --prompt='  ' \
    --preview='eza -lah --icons=auto --git --color=always -- "{}"')" || return
  [[ -n "$selected" ]] && builtin cd -- "$selected"
}

lsi() {
  eza --icons=auto
  cdi "${1:-.}"
}

# ==================================================
# Interactive tools
# ==================================================

# Frecency-based directory jumping: `z <directory fragment>`.
eval "$(zoxide init zsh)"

# AURORA floating palette shared by fzf history, directory picking, and files.
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border=rounded --style=full --border-label=' 󰍉  AURORA FINDER ' --prompt='  ' --pointer='❯' --marker='✓' --color=fg:#E6EEF8,bg:#0D1424,hl:#59E1FF,fg+:#FFFFFF,bg+:#223A63,hl+:#FF7AC6,info:#5F6E86,prompt:#59E1FF,pointer:#BE8CFF,marker:#8FF0A4,spinner:#59E1FF,header:#AAB7CB,border:#59E1FF,separator:#315779,scrollbar:#6C9DFF"
export FZF_CTRL_R_OPTS="--border-label=' 󰋚  COMMAND HISTORY ' --prompt='󰋚  '"

# fzf 0.74+ official zsh integration (Ctrl-R history search included).
source <(fzf --zsh)

# Native zsh completion, followed by fzf-tab's fuzzy completion menu.
autoload -Uz compinit
compinit
# Keep Tab completion in the same floating-palette visual language.
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border=rounded --style=full --border-label=' 󰘳  COMPLETION ' --prompt='󰘳  ' --pointer='❯' --marker='✓' --color=fg:#E6EEF8,bg:#0D1424,hl:#59E1FF,fg+:#FFFFFF,bg+:#223A63,hl+:#FF7AC6,info:#5F6E86,prompt:#59E1FF,pointer:#BE8CFF,marker:#8FF0A4,border:#59E1FF,separator:#315779,scrollbar:#6C9DFF
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

# Show history-based command suggestions while typing.
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prompt. Initialize once, after interactive tool setup.
eval "$(starship init zsh)"


# ==================================================
# Syntax Highlight Colors
# ==================================================

# Load last: zsh-syntax-highlighting must be sourced after other widgets.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 正しいコマンド → Electric Cyan
ZSH_HIGHLIGHT_STYLES[command]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#59E1FF,bold'

# 存在しないコマンド → Neon Red
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6384,bold'

# オプション → Solar Gold
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFD166'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFD166'

# パス → Success Green
ZSH_HIGHLIGHT_STYLES[path]='fg=#8FF0A4'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#8FF0A4'

# 文字列 → Neon Violet
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#BE8CFF'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#BE8CFF'

# コメント → Muted Text
ZSH_HIGHLIGHT_STYLES[comment]='fg=#5F6E86'

# 入力予測を控えめなグレーに
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#39465A'
