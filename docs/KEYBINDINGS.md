# Keybindings

以下は `ghostty/config.ghostty` の実際の `keybind` 行から整理したものです。

| Action | Key |
| --- | --- |
| New split right | Cmd + D |
| New split down | Cmd + Shift + D |
| Go to split left | Cmd + Option + Left |
| Go to split right | Cmd + Option + Right |
| Go to split up | Cmd + Option + Up |
| Go to split down | Cmd + Option + Down |
| Toggle split zoom | Cmd + Shift + Enter |
| Command Palette | Cmd + Shift + P |
| Increase font size by 1 | Cmd + = |
| Decrease font size by 1 | Cmd + - |
| Reset font size | Cmd + 0 |
| Toggle Quick Terminal | Ctrl + Option + G (global) |

## Related settings

- `background-opacity = 0.86`
- `background-blur = 30`
- `shell-integration = zsh`
- `notify-on-command-finish = unfocused`
- `notify-on-command-finish-action = notify`

## Hammerspoon

`hammerspoon/terminal.capture.lua` recognizes both `com.apple.Terminal` and `com.mitchellh.ghostty`. The global Ctrl + Option + G binding is defined in Ghostty; Hammerspoon-specific shortcuts are not inferred here.
