# Lightweight AURORA startup HUD. Safe to source from .zshrc.

aurora_startup() {
  [[ -o interactive ]] || return 0
  [[ ${AURORA_STARTUP:-1} != 0 ]] || return 0
  [[ -n ${GHOSTTY_RESOURCES_DIR:-} ]] || return 0
  [[ -z ${SSH_CONNECTION:-} && -z ${CI:-} ]] || return 0

  local cyan=$'\e[38;2;89;225;255m'
  local blue=$'\e[38;2;108;157;255m'
  local violet=$'\e[38;2;190;140;255m'
  local pink=$'\e[38;2;255;122;198m'
  local green=$'\e[38;2;143;240;164m'
  local red=$'\e[38;2;255;99;132m'
  local muted=$'\e[38;2;95;110;134m'
  local text=$'\e[38;2;230;238;248m'
  local reset=$'\e[0m'
  local codex_state="READY" hermes_state="READY"
  local codex_color="$green" hermes_color="$green" display_dir

  command -v codex >/dev/null 2>&1 || { codex_state="NOT FOUND"; codex_color="$red"; }
  command -v hermes >/dev/null 2>&1 || { hermes_state="NOT FOUND"; hermes_color="$red"; }

  if [[ "$PWD" == "$HOME" ]]; then
    display_dir="~"
  elif [[ "$PWD" == "$HOME/"* ]]; then
    display_dir="~/${PWD#"$HOME/"}"
  else
    display_dir="${PWD:t}"
  fi

  printf '\n  %s✦%s AURORA %sCOCKPIT%s\n' "$cyan" "$blue" "$violet" "$reset"
  printf '  %s◈%s Ghostty  %s● ONLINE%s\n' "$blue" "$text" "$green" "$reset"
  printf '  %s󰘧%s zsh      %s● READY%s\n' "$violet" "$text" "$green" "$reset"
  printf '  %s✦%s Codex    %s● %s%s\n' "$cyan" "$text" "$codex_color" "$codex_state" "$reset"
  printf '  %s◆%s Hermes   %s● %s%s\n' "$pink" "$text" "$hermes_color" "$hermes_state" "$reset"
  printf '  %s󰉋%s %s%s\n' "$cyan" "$reset" "$display_dir" "$reset"
  printf '  %s────── ◇ ──────%s\n\n' "$muted" "$reset"

  # Legacy switch: AURORA_METRICS=0 suppresses any startup monitor.
  [[ ${AURORA_METRICS:-1} != 0 ]] || return 0

  case "${AURORA_MONITOR:-btop}" in
    btop)
      # btop is a full-screen TUI; skip it for non-TTY and `zsh -i -c`
      # invocations (including shell startup benchmarks).
      if [[ -t 0 && -t 1 && -z ${ZSH_EXECUTION_STRING:-} ]] && command -v btop >/dev/null 2>&1; then
        command btop
      elif ! command -v btop >/dev/null 2>&1 && (( $+functions[aurora_engine_metrics] )); then
        # Preserve the old metrics HUD on machines not yet running brew bundle.
        aurora_engine_metrics
      fi
      ;;
    metrics)
      (( $+functions[aurora_engine_metrics] )) && aurora_engine_metrics
      ;;
    off)
      ;;
    *)
      printf 'AURORA: unsupported AURORA_MONITOR=%s (expected btop, metrics, or off)\n' "${AURORA_MONITOR}" >&2
      ;;
  esac
  return 0
}
