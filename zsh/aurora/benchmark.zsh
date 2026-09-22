# AURORA shell startup benchmark helpers.

aurora_bench() {
  emulate -L zsh
  local runs="${1:-10}"
  command -v hyperfine >/dev/null 2>&1 || { print -u2 "AURORA: hyperfine is required"; return 1; }
  [[ "$runs" == <-> ]] || { print -u2 "usage: aurora_bench [runs]"; return 2; }

  hyperfine --warmup 3 --runs "$runs" \
    'zsh -i -c exit' \
    'AURORA_STARTUP=0 AURORA_METRICS=0 zsh -i -c exit'
}

# Detailed startup profile: launch with AURORA_ZPROF=1 zsh -i, then run this.
aurora_zprof() {
  if zmodload -e zsh/zprof; then
    zprof
  else
    print -u2 "AURORA: start a shell with AURORA_ZPROF=1 zsh -i first"
    return 1
  fi
}
