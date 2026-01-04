# Flutter E2E Investigation

**AI駆動開発の次のステージ**を検証するプロジェクトです。

Claude Code + MCP (Maestro / Dart) を組み合わせ、AIが**設計・実装・動作確認・セルフレビュー**まで自律的に行います。

## Why This Matters?

### 従来のAI駆動開発：ペアプログラミング的

```
人間 ←→ AI
  ↑
 毎ステップで確認・判断
```

実装ごとに人間がコードレビュー、動作確認も人間が目視。
AIは「手を動かす人」、人間は「常に横で見ている人」。

**問題**: 人間の時間的コストが高く、AIの生産性を活かしきれない。

### 目指す姿：チームメンバーへの委任的

```
人間（リードエンジニア）
  ↓ タスク依頼
AI（チームメンバー）
  ├── 実装
  ├── 動作確認（E2Eテスト、エラー確認）
  ├── セルフレビュー（複数モデルで検証）
  └── 完成度を高めてから報告
  ↓
人間（最終レビュー・承認）
```

**変化**: 人間は「最終確認者」になり、AIが自律的に品質を担保。

### 人間のチーム運営と同じ

```
ジュニア:
  1. 実装
  2. 自分で動作確認
  3. テスト通るか確認
  4. セルフレビュー（明らかな問題を潰す）
  5. 「確認しました、レビューお願いします」
    ↓
シニア: 本質的な部分だけレビュー
```

これができて初めて、シニア1人で複数のジュニアを見られる。
**AIエージェントも同じ。** 自己検証できなければ、人間がボトルネックになる。

### スケーラビリティ

```
                    ┌─ AI Agent A（機能実装）
                    │    └─ セルフテスト・レビュー
人間（リード）──────┼─ AI Agent B（バグ修正）
                    │    └─ セルフテスト・レビュー
                    └─ AI Agent C（リファクタ）
                         └─ セルフテスト・レビュー
```

AIエージェントを並列稼働させるには、人間がボトルネックにならない仕組みが必須。
このプロジェクトは**その基盤技術の実証**。

## What's This?

このリポジトリは、AI（Claude Code）が以下を**すべて自律的に**実行することを実証しています：

- Flutter アプリの設計・実装
- E2E テストによる動作確認
- セルフレビュー（Gemini CLI + Claude subagent）
- Git コミット・プッシュ

**人間が行うのは指示と最終レビューだけ。**

## Demo: 画像添付機能の実装

「画像添付機能を実装して」という一言から、Claude Code が：

1. 設計を提案し、ユーザーに確認
2. 必要なパッケージを追加
3. モデル・リポジトリ・プロバイダーを実装
4. UI ウィジェットを作成
5. **エミュレーターでアプリを起動**
6. **実際に操作して動作確認**
7. スクリーンショットで結果を報告

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       Claude Code                            │
├─────────────────────────────────────────────────────────────┤
│  Plan Mode    │  Implementation  │  E2E Testing            │
│  ・設計        │  ・コード生成     │  ・アプリ起動            │
│  ・質問        │  ・ファイル編集   │  ・UI操作               │
│  ・承認取得    │  ・進捗管理       │  ・スクリーンショット    │
└───────┬───────┴────────┬─────────┴───────────┬─────────────┘
        │                │                     │
        ▼                ▼                     ▼
   AskUserQuestion    Edit/Write         MCP Servers
                                              │
                    ┌─────────────────────────┼─────────────────────────┐
                    │                         │                         │
                    ▼                         ▼                         ▼
              ┌──────────┐             ┌──────────┐             ┌──────────┐
              │ Dart MCP │             │ Maestro  │             │ Flutter  │
              │  Server  │             │   MCP    │             │   App    │
              └────┬─────┘             └────┬─────┘             └──────────┘
                   │                        │                         ▲
                   │  ・アプリ起動           │  ・スクリーンショット    │
                   │  ・ホットリロード       │  ・タップ操作           │
                   │  ・ウィジェットツリー   │  ・テキスト入力         │
                   │  ・エラー取得          │  ・view hierarchy       │
                   │                        │                         │
                   └────────────────────────┴─────────────────────────┘
```

## Key Features

### Dart MCP Server
- `launch_app`: Flutter アプリの起動
- `connect_dart_tooling_daemon`: DTD 接続
- `hot_reload` / `hot_restart`: コード変更の即時反映
- `get_widget_tree`: ウィジェット構造の取得
- `get_runtime_errors`: エラー情報の取得

### Maestro MCP
- `take_screenshot`: スクリーンショット取得
- `inspect_view_hierarchy`: UI 要素一覧（軽量）
- `tap_on`: テキスト/ID 指定でタップ
- `input_text`: テキスト入力
- `run_flow`: Maestro フロー実行

### Self Review（セルフレビュー）
- **Gemini CLI**: 外部モデル視点でのレビュー
- **Claude subagent**: 別コンテキストでのレビュー
- **観点**: コード品質、バグ・エラー、設計パターン
- **判定**: PASS / MINOR / FAIL → 問題があれば自己修正

## Development Flow

Claude Code が実行する開発フロー：

```
1. Plan Mode（設計）
   └─ 不明点をユーザーに質問 → 計画作成 → 承認取得

2. Implementation（実装）
   └─ TodoWrite でタスク管理 → コード生成・編集

3. E2E Testing（動作確認）
   └─ アプリ起動 → UI操作 → 結果確認

4. Self Review（セルフレビュー）
   └─ Gemini CLI + Claude subagent でデュアルレビュー
   └─ 問題があれば自己修正 → 再レビュー

5. Git Operations
   └─ コミット → プッシュ → 人間に最終レビュー依頼
```

### 効率的な E2E テスト

```
✅ 推奨: hierarchy → 操作 → hierarchy → ... → screenshot（最終確認）
❌ 非効率: screenshot → 操作 → screenshot → ...
```

`inspect_view_hierarchy` は軽量で高速。スクリーンショットは視覚確認が必要な時のみ。

### Widget 選択からの実装フロー

`/inspect-widget` コマンドを使って、シミュレーターで選択した Widget を起点に修正を行うワークフロー：

```
1. /inspect-widget 実行
   └─ Dart MCP: Widget選択モード有効化
   └─ ユーザー: シミュレーターでWidgetをタップ選択

2. Widget 調査
   └─ Dart MCP: get_selected_widget でWidget情報取得
   └─ ソースコード位置・プロパティを確認

3. 修正指示 → Plan Mode
   └─ ユーザー: 「3状態にしたい」等の修正指示
   └─ Claude: 関連コード調査 → 実装計画作成

4. 実装
   └─ TodoWrite でタスク管理
   └─ コード編集 → hot_reload で即時反映

5. 動作確認
   └─ Maestro MCP: inspect_view_hierarchy で状態確認
   └─ Maestro MCP: tap_on で操作テスト
   └─ Maestro MCP: take_screenshot で最終確認
```

**実例**: 完了フィルターの3状態化

```
User: (シミュレーターでフィルターアイコンを選択)
User: 「3状態にしたい - すべて/完了済み/未完了」

Claude:
  1. get_selected_widget → todo_list_screen.dart:92 の Icon 特定
  2. Plan Mode → CompletionFilter enum 設計
  3. 実装 → 6ファイル修正
  4. Maestro で3状態サイクルを自動テスト
  5. スクリーンショットで報告
```

この流れにより、**「ここを直したい」→ 選択 → 修正 → 確認** が一気通貫で完了します。

## Sample App: TODO

検証用に作成した TODO アプリ：

- **State Management**: Riverpod (AsyncNotifier)
- **Persistence**: SharedPreferences
- **Features**:
  - タスクの CRUD
  - カテゴリ分類
  - 期限設定
  - 画像添付
  - 検索・フィルター

## Setup

### Prerequisites

- Flutter SDK
- Android Emulator / iOS Simulator
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
- [Maestro MCP](https://github.com/mobile-next/maestro-mcp)

### MCP Configuration

```json
{
  "mcpServers": {
    "dart-mcp": {
      "command": "dart",
      "args": ["run", "dart_mcp_server"],
      "cwd": "/path/to/dart_mcp_server"
    },
    "maestro": {
      "command": "npx",
      "args": ["-y", "@anthropic/maestro-mcp@latest"]
    }
  }
}
```

## Links

- [Maestro - Flutter Testing](https://docs.maestro.dev/platform-support/flutter)
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
- [Claude Code](https://claude.ai/code)

## License

MIT
