# Keybindings

以下は `ghostty/config.ghostty` の実際の `keybind` 行から整理したものです。

| Action | Key |
| --- | --- |
| New split right | Cmd + D |
| New split down | Cmd + Shift + D |
| Go to split | Cmd + Option + Arrow |
| Resize split | Ctrl + Option + Shift + Arrow |
| Equalize splits | Cmd + Option + 0 |
| Toggle split zoom | Cmd + Shift + Enter |
| Previous prompt | Cmd + Option + K |
| Next prompt | Cmd + Option + J |
| Command Palette | Cmd + Shift + P |
| Increase font size by 1 | Cmd + = |
| Decrease font size by 1 | Cmd + - |
| Reset font size | Cmd + 0 |
| Toggle Quick Terminal | Ctrl + Option + G (global) |

## Related settings

- `window-save-state = always`: window / tab / split状態を復元
- `shell-integration = zsh`
- `shell-integration-features = ssh-env,ssh-terminfo`
- `mouse-hide-while-typing = true`
- `clipboard-paste-protection = true`
- `clipboard-trim-trailing-spaces = true`
- `notify-on-command-finish = unfocused`
- `notify-on-command-finish-action = notify`

`jump_to_prompt`とworking-directory復元はGhostty shell integrationを前提にします。

## Shell/TUI keys

- `Ctrl-R`: Atuin history
- Tab: fzf-tab completion
- `pj`: AURORA Project Launcher
- `y`: Yazi + cwd handoff

## Hammerspoon

`hammerspoon/terminal.capture.lua` recognizes both `com.apple.Terminal` and `com.mitchellh.ghostty`. The global Ctrl + Option + G binding is defined in Ghostty.
