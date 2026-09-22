# AURORA project launcher.
# Override the colon-separated roots with AURORA_PROJECT_ROOTS.

aurora_project_roots() {
  emulate -L zsh
  local raw="${AURORA_PROJECT_ROOTS:-$HOME/Documents:$HOME/Developer:$HOME/Projects}"
  local -a roots
  roots=( "${(@s.:.)raw}" )
  print -rl -- "${roots[@]}"
}

aurora_project_pick() {
  emulate -L zsh
  setopt pipefail

  command -v fd >/dev/null 2>&1 || { print -u2 "AURORA: fd is required"; return 1; }
  command -v fzf >/dev/null 2>&1 || { print -u2 "AURORA: fzf is required"; return 1; }

  local root gitdir selected
  local -a repos

  while IFS= read -r root; do
    [[ -d "$root" ]] || continue
    while IFS= read -r gitdir; do
      gitdir="${gitdir%/}"
      repos+=( "${gitdir:h}" )
    done < <(fd --hidden --type d --max-depth 6 --exclude node_modules --exclude .dart_tool '^\.git$' "$root" 2>/dev/null)
  done < <(aurora_project_roots)

  (( ${#repos} )) || { print -u2 "AURORA: no Git projects found"; return 1; }
  repos=( ${(u)repos} )

  selected="$(print -rl -- "${repos[@]}" | fzf \
    --height=70% --layout=reverse --border=rounded \
    --border-label=' 󰘬  PROJECT LAUNCHER ' --prompt='󰘬  ' \
    --preview='printf "\033[1;36m%s\033[0m\n\n" {}; git -C {} status --short --branch 2>/dev/null; printf "\n"; eza -lah --icons=auto --git --color=always -- {} 2>/dev/null | head -40')" || return 1

  print -r -- "$selected"
}

pj() {
  local selected
  selected="$(aurora_project_pick)" || return
  builtin cd -- "$selected"
}

# Pick a project and start Codex there.
pjc() {
  pj || return
  command codex
}

# Pick a project and open Lazygit there.
pjg() {
  pj || return
  command lazygit
}
