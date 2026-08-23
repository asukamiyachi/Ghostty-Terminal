# macOS-only AURORA ENGINE METRICS. Safe to source from .zshrc.

aurora_engine_metrics() {
  emulate -L zsh
  setopt no_aliases

  local cyan=$'\e[38;2;89;225;255m' blue=$'\e[38;2;108;157;255m'
  local violet=$'\e[38;2;190;140;255m' green=$'\e[38;2;143;240;164m'
  local gold=$'\e[38;2;255;209;102m' red=$'\e[38;2;255;99;132m'
  local muted=$'\e[38;2;95;110;134m' reset=$'\e[0m'
  local cpu_cores cpu_percent cpu_color memory_bytes memory_percent memory_gib memory_color
  local battery_info battery_percent battery_display battery_state battery_color battery_temp
  local network_info network_interface network_state network_color thermal_info thermal_state thermal_color

  cpu_cores="$(sysctl -n hw.ncpu 2>/dev/null)"
  [[ "$cpu_cores" == <-> ]] || cpu_cores=1
  cpu_percent="$(ps -A -o %cpu= 2>/dev/null | awk -v cores="$cpu_cores" '{ total += $1 } END { printf "%d", (total / cores) + 0.5 }')"
  [[ "$cpu_percent" == <-> ]] || cpu_percent=0
  (( cpu_percent > 100 )) && cpu_percent=100
  if (( cpu_percent >= 85 )); then cpu_color="$red"
  elif (( cpu_percent >= 70 )); then cpu_color="$gold"
  else cpu_color="$green"; fi

  memory_bytes="$(sysctl -n hw.memsize 2>/dev/null)"
  [[ "$memory_bytes" == <-> ]] || memory_bytes=0
  read -r memory_percent memory_gib <<< "$(vm_stat 2>/dev/null | awk -v total="$memory_bytes" '
    /^Pages active/ { gsub(/[^0-9]/, "", $3); active = $3 }
    /^Pages wired down/ { gsub(/[^0-9]/, "", $4); wired = $4 }
    /^Pages occupied by compressor/ { gsub(/[^0-9]/, "", $5); compressed = $5 }
    /^Mach Virtual Memory Statistics/ { if (match($0, /page size of [0-9]+/)) size = substr($0, RSTART + 13, RLENGTH - 13) }
    END { used = (active + wired + compressed) * size; if (total > 0) printf "%d %.1f", (used * 100 / total) + 0.5, used / 1073741824; else print "0 0.0" }')"
  [[ "$memory_percent" == <-> ]] || memory_percent=0
  if (( memory_percent >= 85 )); then memory_color="$red"
  elif (( memory_percent >= 70 )); then memory_color="$gold"
  else memory_color="$green"; fi

  battery_info="$(pmset -g batt 2>/dev/null)"
  battery_percent="$(print -r -- "$battery_info" | awk 'match($0, /[0-9]+%/) { print substr($0, RSTART, RLENGTH - 1); exit }')"
  if [[ "$battery_percent" == <-> ]]; then
    case "$battery_info" in
      *charging*) battery_state="CHARGING" ;;
      *discharging*) battery_state="DISCHARGING" ;;
      *charged*) battery_state="CHARGED" ;;
      *) battery_state="BATTERY" ;;
    esac
    if (( battery_percent <= 20 )); then battery_color="$red"
    elif (( battery_percent <= 40 )); then battery_color="$gold"
    else battery_color="$green"; fi
    battery_display="${battery_percent}%"
  else
    battery_percent="AC"; battery_state="EXTERNAL POWER"; battery_color="$cyan"
    battery_display="$battery_percent"
  fi
  battery_temp="$(ioreg -rn AppleSmartBattery -w0 2>/dev/null | awk '/"Temperature" =/ { printf "%d°C", ($3 / 10 - 273.15) + 0.5; exit }')"
  [[ -n "$battery_temp" ]] || battery_temp="TEMP N/A"

  network_info="$(scutil --nwi 2>/dev/null)"
  network_interface="$(print -r -- "$network_info" | awk '/^[[:space:]]+[[:alnum:]]+ : flags/ { print $1; exit }')"
  if [[ "$network_info" == *"REACH"* && -n "$network_interface" ]]; then
    network_state="ONLINE $network_interface"; network_color="$green"
  else
    network_state="OFFLINE"; network_color="$red"
  fi

  thermal_info="$(pmset -g therm 2>/dev/null)"
  if [[ "$thermal_info" == *"No thermal warning level has been recorded"* || "$thermal_info" == *"CPU_Speed_Limit = 100"* ]]; then
    thermal_state="NOMINAL"; thermal_color="$green"
  elif [[ -n "$thermal_info" && "$thermal_info" != *"Error:"* ]]; then
    thermal_state="ELEVATED"; thermal_color="$gold"
  else
    thermal_state="UNAVAILABLE"; thermal_color="$muted"
  fi

  printf '\n  %s╭─ ◈ ENGINE METRICS ───────────────────────╮%s\n' "$cyan" "$reset"
  printf '  %s│%s  %s◜──────────◝%s   %s◜──────────◝%s            %s│%s\n' "$cyan" "$reset" "$blue" "$reset" "$violet" "$reset" "$cyan" "$reset"
  printf '  %s│%s %s╱ CPU  %3s%% ╲%s %s╱ MEMORY %3s%% ╲%s           %s│%s\n' "$cyan" "$reset" "$cpu_color" "$cpu_percent" "$reset" "$memory_color" "$memory_percent" "$reset" "$cyan" "$reset"
  printf '  %s│%s %s╲ LOAD       ╱%s %s╲ %5s GB ╱%s           %s│%s\n' "$cyan" "$reset" "$cpu_color" "$reset" "$memory_color" "$memory_gib" "$reset" "$cyan" "$reset"
  printf '  %s│%s  %s◟──────────◞%s   %s◟──────────◞%s            %s│%s\n' "$cyan" "$reset" "$blue" "$reset" "$violet" "$reset" "$cyan" "$reset"
  printf '  %s│%s                                            %s│%s\n' "$cyan" "$reset" "$cyan" "$reset"
  printf '  %s│%s  %s◜──────────◝%s   %s◜──────────◝%s            %s│%s\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset" "$cyan" "$reset"
  printf '  %s│%s %s╱ POWER %-4s ╲%s %s╱ NETWORK     ╲%s           %s│%s\n' "$cyan" "$reset" "$battery_color" "$battery_display" "$reset" "$network_color" "$reset" "$cyan" "$reset"
  printf '  %s│%s %s╲ %-11s╱%s %s╲ %-11s╱%s           %s│%s\n' "$cyan" "$reset" "$battery_color" "$battery_state" "$reset" "$network_color" "$network_state" "$reset" "$cyan" "$reset"
  printf '  %s│%s  %s◟──────────◞%s   %s◟──────────◞%s            %s│%s\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset" "$cyan" "$reset"
  printf '  %s│%s                                            %s│%s\n' "$cyan" "$reset" "$cyan" "$reset"
  printf '  %s│%s         %s◜────────────────────◝%s         %s│%s\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
  printf '  %s│%s        %s╱ THERMAL  %-10s ╲%s        %s│%s\n' "$cyan" "$reset" "$thermal_color" "$battery_temp" "$reset" "$cyan" "$reset"
  printf '  %s│%s        %s╲ %-19s╱%s        %s│%s\n' "$cyan" "$reset" "$thermal_color" "$thermal_state" "$reset" "$cyan" "$reset"
  printf '  %s│%s         %s◟────────────────────◞%s         %s│%s\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
  printf '  %s╰───────────────────────────────────────────╯%s\n' "$cyan" "$reset"
}
