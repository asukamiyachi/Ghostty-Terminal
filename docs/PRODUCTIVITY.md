# Productivity Stack

AURORA COCKPITの生産性機能を、役割が重ならないように分離しています。

## History — Atuin

`Ctrl-R`はAtuinが担当します。

- Git repository内ではworkspace filterを優先
- cwd / timestamp / duration / exit codeを保存
- `enter_accept = false`のため、候補選択後にコマンドラインで確認してから実行
- Up ArrowはAtuinに奪わせない
- syncは自動設定しない

## Completion — Carapace + fzf-tab

Carapaceはcompletion候補を増やし、fzf-tabが表示UIを担当します。

Carapaceの生成スクリプトは毎回生成せず、`~/.cache/aurora/carapace.zsh`へキャッシュします。Carapace binaryが更新された場合のみ再生成します。

## Project Launcher

`pj`は設定されたproject rootsからGit repositoryを探し、fzf preview付きで選択します。

- `pj`: cdのみ
- `pjc`: cd後にCodex
- `pjg`: cd後にLazygit

探索rootは `AURORA_PROJECT_ROOTS` で変更できます。

## Runtime — mise

miseはinteractive zshでactivateし、project directory移動時にruntimeとenvironmentを切り替えます。

各project側で `mise.toml` を管理してください。このrepoではNodeやPythonのglobal versionを強制しません。

## Files — Yazi

`y` wrapperでYaziを開き、終了時にYazi上のcwdを現在のzshへ反映します。

## Prompt

Starshipは常時情報を増やしすぎない方針です。

- Node: Node projectだけ
- Dart: Flutter/Dart projectだけ
- Python: Python project / venvだけ
- package version: package metadataがある場合
- exit status: failure時だけ
- command duration: 1.5秒以上
- current time: HH:MM:SS

CPU/RAM/Powerなどは毎promptではなくStartup HUD / `aurora_engine_metrics`へ分離しています。

## Performance

`aurora_bench [runs]`で以下を比較します。

1. AURORAを含む通常interactive shell
2. Startup HUD / Engine Metricsを切ったcore shell

詳細調査は `AURORA_ZPROF=1 zsh -i` → `aurora_zprof`。

運用上は平均起動時間だけでなく、変更前から25%以上悪化した場合を回帰候補として確認します。
