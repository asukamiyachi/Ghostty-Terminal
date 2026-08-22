# Troubleshooting

## Ghostty config error

```bash
ghostty +validate-config
```

エラーが出た場合、`ghostty/config.ghostty`を最後に動作していたバックアップへ戻し、追加した行を一つずつ確認します。

## zsh error

```bash
zsh -n ~/.zshrc
```

実際の読み込み確認:

```bash
zsh -i -c 'whence -w z compinit _fzf-tab-apply; bindkey "^I"'
```

## PATH

```bash
echo "$PATH"
command -v brew git node flutter codex hermes
```

Hermesの期待値は `$HOME/.local/bin/hermes` です。

## fzf-tab

`fzf-tab`は実行ファイルではありません。次は見つからなくても異常ではありません。

```bash
command -v fzf-tab
```

プラグインの読み込みは次で確認します。

```bash
zsh -i -c 'whence -w _fzf-tab-apply; bindkey "^I"'
```

Tabキーが`fzf-tab-complete`なら読み込み成功です。

## Hermes not found

```bash
command -v hermes
```

見つからない場合は、`$HOME/.local/bin`がPATHに含まれることを確認してください。認証情報やAPIキーをREADME・設定ファイルへ追加しないでください。

## Restore

設定配置前に作成したバックアップから、対象ファイルだけを戻してください。バックアップがない状態で上書きしないでください。
