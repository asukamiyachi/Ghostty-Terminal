#!/bin/zsh
# Emit one ANSI-styled AURORA Git HUD pill from a single git-status call.

aurora_git_pill() {
  emulate -L zsh
  setopt no_aliases

  local git_status line branch="" ahead=0 behind=0 staged=0 modified=0 untracked=0 conflicts=0
  local xy state color background void=$'\e[38;2;5;7;13m' reset=$'\e[0m'

  git_status="$(LC_ALL=C command git status --porcelain=v2 --branch 2>/dev/null)" || return 0

  while IFS= read -r line; do
    case "$line" in
      '# branch.head '*) branch="${line#\# branch.head }" ;;
      '# branch.ab '*)
        local -a counts
        counts=( ${(s: :)${line#\# branch.ab }} )
        ahead="${counts[1]#+}"
        behind="${counts[2]#-}"
        ;;
      '1 '*|'2 '*)
        xy="${line#? }"
        xy="${xy%% *}"
        [[ "${xy[1]}" != '.' ]] && ((staged++))
        [[ "${xy[2]}" != '.' ]] && ((modified++))
        ;;
      '? '*) ((untracked++)) ;;
      'u '*) ((conflicts++)) ;;
    esac
  done <<< "$git_status"

  [[ -n "$branch" && "$branch" != "(detached)" ]] || branch="DETACHED"
  branch="${branch//[^A-Za-z0-9._\/-]/_}"
  (( ${#branch} > 28 )) && branch="${branch[1,27]}…"

  if (( conflicts > 0 )); then
    state="!${conflicts}"
    color=$'\e[38;2;255;99;132m'
    background=$'\e[48;2;255;99;132m'
  elif (( ahead > 0 && behind > 0 )); then
    state="⇕${ahead}/${behind}"
    color=$'\e[38;2;190;140;255m'
    background=$'\e[48;2;190;140;255m'
  elif (( staged + modified + untracked > 0 )); then
    state=""
    (( staged > 0 )) && state+="+${staged} "
    (( modified > 0 )) && state+="●${modified} "
    (( untracked > 0 )) && state+="?${untracked} "
    state="${state% }"
    color=$'\e[38;2;255;209;102m'
    background=$'\e[48;2;255;209;102m'
  elif (( ahead > 0 )); then
    state="⇡${ahead}"
    color=$'\e[38;2;89;225;255m'
    background=$'\e[48;2;89;225;255m'
  elif (( behind > 0 )); then
    state="⇣${behind}"
    color=$'\e[38;2;255;209;102m'
    background=$'\e[48;2;255;209;102m'
  else
    state="✓"
    color=$'\e[38;2;143;240;164m'
    background=$'\e[48;2;143;240;164m'
  fi

  print -rn -- "${color}${background}${void}  ${branch} ${state} ${reset}${color}${reset}"
}

aurora_git_pill "$@"
