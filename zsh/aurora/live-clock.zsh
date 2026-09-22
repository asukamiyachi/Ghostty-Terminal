# AURORA live prompt clock.
#
# Starship keeps rendering $time in its normal prompt position. While ZLE is
# active, this module asks ZLE to regenerate the prompt once per second so the
# clock advances in place without writing new terminal lines.
#
# On Enter, the prompt is redrawn one final time and then the timer is stopped.
# That leaves the command's launch time frozen in scrollback while the command
# runs. The next prompt starts a fresh live clock. Disable with
# AURORA_LIVE_CLOCK=0.

[[ -o interactive ]] || return 0
[[ ${AURORA_LIVE_CLOCK:-1} != 0 ]] || return 0
[[ -n ${_AURORA_LIVE_CLOCK_LOADED:-} ]] && return 0
typeset -g _AURORA_LIVE_CLOCK_LOADED=1

autoload -Uz add-zle-hook-widget

typeset -g _AURORA_LIVE_CLOCK_FD=""

_aurora_live_clock_stop() {
  emulate -L zsh

  if [[ -n ${_AURORA_LIVE_CLOCK_FD:-} ]]; then
    zle -F "$_AURORA_LIVE_CLOCK_FD" 2>/dev/null
    exec {_AURORA_LIVE_CLOCK_FD}<&- 2>/dev/null
    _AURORA_LIVE_CLOCK_FD=""
  fi
}

_aurora_live_clock_tick() {
  emulate -L zsh
  local fd="$1"
  local tick

  if ! IFS= read -r -u "$fd" tick 2>/dev/null; then
    _aurora_live_clock_stop
    return 0
  fi

  # reset-prompt regenerates Starship's $time while preserving BUFFER/CURSOR.
  zle reset-prompt
}

_aurora_live_clock_start() {
  emulate -L zsh

  _aurora_live_clock_stop

  exec {_AURORA_LIVE_CLOCK_FD}< <(
    while sleep 1; do
      print -r -- tick
    done
  )

  zle -F "$_AURORA_LIVE_CLOCK_FD" _aurora_live_clock_tick
}

_aurora_live_clock_line_init() {
  _aurora_live_clock_start
}

_aurora_live_clock_line_finish() {
  # Freeze the most recent wall-clock second into the accepted prompt before
  # ZLE hands control to the command.
  zle reset-prompt
  _aurora_live_clock_stop
}

add-zle-hook-widget line-init _aurora_live_clock_line_init
add-zle-hook-widget line-finish _aurora_live_clock_line_finish
