# ==================================================
# Shell environment / optional profiling
# ==================================================

# Enable zprof before the rest of startup when explicitly requested.
if [[ ${AURORA_ZPROF:-0} == 1 ]]; then
  zmodload zsh/zprof
fi

# Keep local tools (Hermes), Homebrew tools, and npm globals available.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:$HOME/.npm-global/bin:$PATH"
typeset -U path PATH

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# ==================================================
# Aliases and navigation helpers
# ==================================================

alias cx='codex'
alias ls='eza --icons=auto'
alias ll='eza -lah --icons=auto --git'
alias tree='eza --tree --icons=auto'

# Interactive directory picker.
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

# Yazi wrapper: leave the shell in the directory selected inside Yazi.
y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")" || return
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]] && builtin cd -- "$cwd"
  command rm -f -- "$tmp"
}

# ==================================================
# Interactive tools
# ==================================================

# Project-scoped tool versions/environment.
command -v mise >/dev/null 2>&1 && eval "$(mise activate zsh)"

# Frecency-based directory jumping: `z <directory fragment>`.
eval "$(zoxide init zsh)"

# AURORA floating palette shared by fzf pickers.
export FZF_DEFAULT_OPTS="--height=60% --layout=reverse --border=rounded --style=full --border-label=' 󰍉  AURORA FINDER ' --prompt='  ' --pointer='❯' --marker='✓' --color=fg:#E6EEF8,bg:#0D1424,hl:#59E1FF,fg+:#FFFFFF,bg+:#223A63,hl+:#FF7AC6,info:#5F6E86,prompt:#59E1FF,pointer:#BE8CFF,marker:#8FF0A4,spinner:#59E1FF,header:#AAB7CB,border:#59E1FF,separator:#315779,scrollbar:#6C9DFF"

# fzf keeps file/directory widgets; Ctrl-R is intentionally overridden by Atuin below.
source <(fzf --zsh)

# Native zsh completion.
autoload -Uz compinit
compinit

# Carapace completion is cached so shell startup does not regenerate it each time.
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  _aurora_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/aurora"
  _aurora_carapace_cache="$_aurora_cache_dir/carapace.zsh"
  if [[ ! -s "$_aurora_carapace_cache" || "${commands[carapace]}" -nt "$_aurora_carapace_cache" ]]; then
    mkdir -p "$_aurora_cache_dir"
    if carapace _carapace zsh >| "$_aurora_carapace_cache.tmp" 2>/dev/null; then
      mv -f "$_aurora_carapace_cache.tmp" "$_aurora_carapace_cache"
    else
      rm -f "$_aurora_carapace_cache.tmp"
    fi
  fi
  [[ -r "$_aurora_carapace_cache" ]] && source "$_aurora_carapace_cache"
  unset _aurora_cache_dir _aurora_carapace_cache
fi

# Keep Tab completion in the same floating-palette visual language.
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse --border=rounded --style=full --border-label=' 󰘳  COMPLETION ' --prompt='󰘳  ' --pointer='❯' --marker='✓' --color=fg:#E6EEF8,bg:#0D1424,hl:#59E1FF,fg+:#FFFFFF,bg+:#223A63,hl+:#FF7AC6,info:#5F6E86,prompt:#59E1FF,pointer:#BE8CFF,marker:#8FF0A4,border:#59E1FF,separator:#315779,scrollbar:#6C9DFF
source /opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh

# Suggestions can come from both history and completion metadata.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Atuin owns Ctrl-R but leaves the normal Up arrow untouched.
command -v atuin >/dev/null 2>&1 && eval "$(atuin init zsh --disable-up-arrow --disable-ai)"

# Prompt. Initialize once, after interactive tool setup.
eval "$(starship init zsh)"

# AURORA modules.
for _aurora_module in "$HOME/.config/aurora/project-launcher.zsh" "$HOME/.config/aurora/benchmark.zsh" "$HOME/.config/aurora/startup.zsh" "$HOME/.config/aurora/engine-metrics.zsh"; do
  [[ -r "$_aurora_module" ]] && source "$_aurora_module"
done
unset _aurora_module

# ==================================================
# Syntax Highlight Colors
# ==================================================

# Load last: zsh-syntax-highlighting must be sourced after other widgets.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_STYLES[command]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#59E1FF,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#FF6384,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#FFD166'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#FFD166'
ZSH_HIGHLIGHT_STYLES[path]='fg=#8FF0A4'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#8FF0A4'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#BE8CFF'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#BE8CFF'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#5F6E86'
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#39465A'

# Runs only in a local interactive Ghostty shell. Disable with AURORA_STARTUP=0.
(( $+functions[aurora_startup] )) && aurora_startup
