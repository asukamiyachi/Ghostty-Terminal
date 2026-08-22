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
    --height=60% --layout=reverse --border --prompt='dir > ' \
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

# fzf 0.74+ official zsh integration (Ctrl-R history search included).
source <(fzf --zsh)

# Native zsh completion, followed by fzf-tab's fuzzy completion menu.
autoload -Uz compinit
compinit
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

# 正しいコマンド → Cyan
ZSH_HIGHLIGHT_STYLES[command]='fg=#7DCFFF,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7DCFFF,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#7DCFFF,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7DCFFF,bold'

# 存在しないコマンド → Red
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#F7768E,bold'

# オプション → Yellow
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#E0AF68'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#E0AF68'

# パス → Green
ZSH_HIGHLIGHT_STYLES[path]='fg=#9ECE6A'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#9ECE6A'

# 文字列 → Purple
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#BB9AF7'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#BB9AF7'

# コメント → Gray
ZSH_HIGHLIGHT_STYLES[comment]='fg=#565F89'

# 入力予測を控えめなグレーに
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#414868'
