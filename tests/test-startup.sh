#!/usr/bin/env bash
# Integration tests for AURORA's startup HUD without requiring Ghostty/macOS.
# Linux util-linux `script` provides a pseudo-TTY so zsh's -t checks are real.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/zdot" "$tmp/bin"
export AURORA_REPO_ROOT="$repo_root"
export AURORA_TEST_LOG="$tmp/events"
export ZDOTDIR="$tmp/zdot"
export GHOSTTY_RESOURCES_DIR="$tmp/ghostty"
export PATH="$tmp/bin:$PATH"

cat > "$tmp/zdot/.zshrc" <<'EOF'
aurora_engine_metrics() {
  print -r -- metrics >> "$AURORA_TEST_LOG"
}
source "$AURORA_REPO_ROOT/zsh/aurora/startup.zsh"
aurora_startup
print -r -- post-startup >> "$AURORA_TEST_LOG"
EOF

# -f suppresses global/user rc files (the CI image can run compinit).
# -i keeps the interactive flag; a script file keeps ZSH_EXECUTION_STRING empty.
cat > "$tmp/harness.zsh" <<'EOF'
source "$ZDOTDIR/.zshrc"
EOF

cat > "$tmp/bin/btop" <<'EOF'
#!/usr/bin/env bash
printf 'btop\n' >> "$AURORA_TEST_LOG"
exit "${AURORA_FAKE_BTOP_EXIT:-0}"
EOF
chmod +x "$tmp/bin/btop"

assert_events() {
  local scenario="$1" expected="$2" actual
  actual="$(cat "$AURORA_TEST_LOG")"
  if [[ "$actual" != "$expected" ]]; then
    printf 'FAIL [%s] expected %q, got %q\n' "$scenario" "$expected" "$actual" >&2
    cat "$tmp/output" >&2
    exit 1
  fi
  printf 'PASS %s\n' "$scenario"
}

# Arguments after the expected events are temporary environment overrides.
# A fake executable on PATH records whether the full-screen btop path is taken.
tty_case() {
  local name="$1" expected="$2"
  shift 2
  : > "$AURORA_TEST_LOG"
  if ! env -u CI -u SSH_CONNECTION -u AURORA_MONITOR -u AURORA_STARTUP -u AURORA_METRICS \
    TERM=xterm-256color "$@" script -q -e -c "zsh -fi '$tmp/harness.zsh'" /dev/null </dev/null > "$tmp/output" 2>&1; then
    printf 'FAIL [%s] PTY execution failed; terminal output:\n' "$name" >&2
    cat "$tmp/output" >&2
    exit 1
  fi
  assert_events "$name" "$expected"
}

tty_case 'default btop and prompt recovery' $'btop\npost-startup'
tty_case 'legacy metrics selection' $'metrics\npost-startup' AURORA_MONITOR=metrics
tty_case 'explicitly disable monitor' 'post-startup' AURORA_MONITOR=off
tty_case 'legacy disable switch' 'post-startup' AURORA_METRICS=0
tty_case 'startup entirely disabled' 'post-startup' AURORA_STARTUP=0
tty_case 'CI skips HUD and monitor' 'post-startup' CI=1
tty_case 'SSH skips HUD and monitor' 'post-startup' SSH_CONNECTION=remote
tty_case 'TERM=dumb skips monitor' 'post-startup' TERM=dumb
tty_case 'nonzero btop exit still reaches shell' $'btop\npost-startup' AURORA_FAKE_BTOP_EXIT=42

# The fake btop is removed from PATH in this test; no system btop is expected
# in the CI runner. Any installed executable would make this test invalid.
if PATH=/usr/bin:/bin command -v btop >/dev/null 2>&1; then
  printf 'FAIL missing-btop test requires a runner without system btop\n' >&2
  exit 1
fi
tty_case 'missing btop falls back to metrics' $'metrics\npost-startup' PATH=/usr/bin:/bin

: > "$AURORA_TEST_LOG"
env -u CI -u SSH_CONNECTION -u AURORA_MONITOR \
  zsh -fi "$tmp/harness.zsh" > "$tmp/output" 2>&1
assert_events 'non-TTY shell skips startup' 'post-startup'

: > "$AURORA_TEST_LOG"
env -u CI -u SSH_CONNECTION -u AURORA_MONITOR \
  zsh -fic 'source "$ZDOTDIR/.zshrc"' > "$tmp/output" 2>&1
assert_events 'interactive -c command skips startup' 'post-startup'

echo 'AURORA startup integration tests passed.'
