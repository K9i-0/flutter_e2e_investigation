# Project Instructions

## プロジェクト概要

AI駆動開発の自律性を検証するプロジェクト。
Claude Codeが「設計・実装・動作確認・セルフレビュー」まで自律的に行う。

## Plan Mode ルール

### 機能実装時の計画には必ず動作確認を含める

Planモードで機能実装の計画を立てる際は、以下のフェーズをすべて含めること：

1. **設計** - 技術選定、アーキテクチャ決定
2. **実装** - コード生成・編集
3. **動作確認** - Maestro/Dart MCPでのE2Eテスト
4. **セルフレビュー** - `/self-review` スキルの実行

実装だけで計画を終わらせない。動作確認まで含めて初めて完了。

### 計画テンプレート例

```
## 実装計画

### 1. 設計
- [ ] 技術調査・選定
- [ ] アーキテクチャ設計

### 2. 実装
- [ ] モデル/リポジトリ層
- [ ] プロバイダー層
- [ ] UI層

### 3. 動作確認
- [ ] アプリ起動（Dart MCP: launch_app）
- [ ] UI操作テスト（Maestro: tap_on, input_text）
- [ ] 状態確認（inspect_view_hierarchy）
- [ ] スクリーンショット（take_screenshot）

### 4. セルフレビュー
- [ ] /self-review 実行
- [ ] 指摘事項の修正
```

## E2E テスト ベストプラクティス

### 効率的なテスト手順

```
✅ 推奨: hierarchy → 操作 → hierarchy → ... → screenshot（最終確認）
❌ 非効率: screenshot → 操作 → screenshot → ...
```

- `inspect_view_hierarchy` は軽量で高速、積極的に使う
- `take_screenshot` は視覚確認が必要な時のみ

### MCP ツール使い分け

| 目的 | ツール |
|------|--------|
| アプリ起動 | Dart MCP: `launch_app` |
| 接続 | Dart MCP: `connect_dart_tooling_daemon` |
| コード反映 | Dart MCP: `hot_reload` / `hot_restart` |
| Widget構造 | Dart MCP: `get_widget_tree` |
| エラー確認 | Dart MCP: `get_runtime_errors` |
| UI要素一覧 | Maestro: `inspect_view_hierarchy` |
| タップ操作 | Maestro: `tap_on` |
| テキスト入力 | Maestro: `input_text` |
| スクリーンショット | Maestro: `take_screenshot` |

## 開発フロー

```
Plan Mode → 実装 → 動作確認 → セルフレビュー → Git操作
```

各フェーズを省略せず、自律的に完了まで進める。
人間が行うのは指示と最終レビューのみ。

## 利用可能なスキル/コマンド

| コマンド | 説明 |
|----------|------|
| `/self-review` | セルフレビュー（Gemini CLI + Claude subagent） |
| `/inspect-widget` | シミュレーターでWidget選択→調査・修正 |
| `/agent-review` | 別視点でのコードレビュー |

## Hooks（自動実行）

- **Edit/Write後**: 自動で `dart analyze` 実行
- **Stop前**: テスト・解析チェック実行

## CLI vs MCP 使い分け

**原則: DTD接続が必要な操作はMCP、それ以外はCLI**

### CLI推奨（MCPより効率的）

| 操作 | コマンド |
|------|----------|
| デバイス一覧 | `flutter devices` |
| テスト実行 | `flutter test` |
| 静的解析 | `dart analyze` |
| フォーマット | `dart format .` |
| 依存関係 | `flutter pub add/get` |
| ビルド | `flutter build ios/apk` |

### MCP必須（DTD接続が必要）

- `launch_app`, `hot_reload`, `hot_restart`
- `get_widget_tree`, `get_runtime_errors`

## コーディング規約

| 対象 | 規約 |
|------|------|
| ファイル名 | `snake_case` |
| クラス名 | `PascalCase` |
| 変数/関数 | `camelCase` |

- E2Eテスト用に `Semantics` を適切に配置
- 状態管理は `Riverpod AsyncNotifier`

## Flutter 開発

- 状態管理: Riverpod (AsyncNotifier)
- 永続化: SharedPreferences
- アーキテクチャ: Repository パターン
