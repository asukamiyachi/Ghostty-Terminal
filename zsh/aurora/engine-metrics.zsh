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
      *discharging*) battery_state="DISCHARGING" ;;
      *charging*) battery_state="CHARGING" ;;
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

  # Rendering deliberately uses ASCII-only grid characters. ANSI codes are
  # separate printf arguments, while %-Ns pads plain visible text only.
  local cpu_primary memory_primary power_primary network_primary thermal_primary thermal_temp
  local cpu_detail memory_detail power_detail network_detail thermal_detail
  local rule_54 rule_42 rule_36 header_rule
  printf -v cpu_primary 'CPU %3d%%  LOAD' "$cpu_percent"
  printf -v memory_primary 'MEMORY %3d%%' "$memory_percent"
  printf -v power_primary 'POWER %-4s' "$battery_display"
  printf -v network_primary 'NETWORK'
  thermal_temp="${battery_temp//°/}"
  printf -v thermal_primary 'THERMAL %s' "$thermal_temp"
  printf -v cpu_detail 'cores: %s' "$cpu_cores"
  printf -v memory_detail 'used: %s GB' "$memory_gib"
  printf -v power_detail '%s' "$battery_state"
  printf -v network_detail '%s' "$network_state"
  printf -v thermal_detail '%s' "$thermal_state"

  if (( ${COLUMNS:-80} >= 60 )); then
    rule_54="${(l:54::-:)}"
    rule_42="${(l:42::-:)}"
    header_rule="${(l:34::-:)}"
    printf '\n  %b+--[ ENGINE METRICS ]%s+%b\n' "$cyan" "$header_rule" "$reset"
    printf '  %b|%b  %b+----------------------+%b  %b+----------------------+%b  %b|%b\n' "$cyan" "$reset" "$blue" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-20s |%b  %b| %-20s |%b  %b|%b\n' "$cyan" "$reset" "$cpu_color" "$cpu_primary" "$reset" "$memory_color" "$memory_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-20s |%b  %b| %-20s |%b  %b|%b\n' "$cyan" "$reset" "$cpu_color" "$cpu_detail" "$reset" "$memory_color" "$memory_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+----------------------+%b  %b+----------------------+%b  %b|%b\n' "$cyan" "$reset" "$blue" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b|%b                                                      %b|%b\n' "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+----------------------+%b  %b+----------------------+%b  %b|%b\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-20s |%b  %b| %-20s |%b  %b|%b\n' "$cyan" "$reset" "$battery_color" "$power_primary" "$reset" "$network_color" "$network_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-20s |%b  %b| %-20s |%b  %b|%b\n' "$cyan" "$reset" "$battery_color" "$power_detail" "$reset" "$network_color" "$network_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+----------------------+%b  %b+----------------------+%b  %b|%b\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b                                                      %b|%b\n' "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b     %b+%s+%b     %b|%b\n' "$cyan" "$reset" "$violet" "$rule_42" "$reset" "$cyan" "$reset"
    printf '  %b|%b     %b| %-40s |%b     %b|%b\n' "$cyan" "$reset" "$thermal_color" "$thermal_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b     %b| %-40s |%b     %b|%b\n' "$cyan" "$reset" "$thermal_color" "$thermal_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b     %b+%s+%b     %b|%b\n' "$cyan" "$reset" "$violet" "$rule_42" "$reset" "$cyan" "$reset"
    printf '  %b+%s+%b\n' "$cyan" "$rule_54" "$reset"
  else
    rule_36="${(l:36::-:)}"
    header_rule="${(l:16::-:)}"
    printf '\n  %b+--[ ENGINE METRICS ]%s+%b\n' "$cyan" "$header_rule" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$blue" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$cpu_color" "$cpu_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$cpu_color" "$cpu_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$blue" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$memory_color" "$memory_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$memory_color" "$memory_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$battery_color" "$power_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$battery_color" "$power_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$gold" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$network_color" "$network_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$network_color" "$network_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$cyan" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$thermal_color" "$thermal_primary" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b| %-28s |%b  %b|%b\n' "$cyan" "$reset" "$thermal_color" "$thermal_detail" "$reset" "$cyan" "$reset"
    printf '  %b|%b  %b+------------------------------+%b  %b|%b\n' "$cyan" "$reset" "$violet" "$reset" "$cyan" "$reset"
    printf '  %b+%s+%b\n' "$cyan" "$rule_36" "$reset"
  fi
}
