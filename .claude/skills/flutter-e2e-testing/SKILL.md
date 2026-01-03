---
name: flutter-e2e-testing
description: FlutterアプリのE2Eテストとモバイル自動化の知見。Maestro、Mobile MCP、Dart MCPを使用したテスト作成・実行時に使用。
---

# Flutter E2E Testing

## 推奨構成: Maestro MCP + Dart MCP

FlutterアプリのE2Eテストと自動化には **Maestro MCP + Dart MCP** の組み合わせが最適。

## ツール概要

### Maestro / Maestro MCP
- Flutter第一級サポートのE2Eテストフレームワーク
- **CLI**: YAMLでテストを記述 (`maestro test .maestro/test.yaml`)
- **MCP**: Claude Codeから対話的に操作（YAML不要）
  - スクリーンショット取得
  - タップ操作（テキスト/id指定、座標計算不要）
  - view hierarchy取得

### Dart MCP Server
- Flutter開発連携用MCPサーバー
- ウィジェットツリー取得（Flutter内部構造）
- ホットリロード/リスタート
- ランタイムエラー取得

### Mobile MCP（参考）
- Maestro MCPで代替可能なため通常は不要
- 座標ベースの操作が必要な特殊ケースでのみ使用

## Maestro + Flutter ベストプラクティス

### Semanticsウィジェットの活用

Maestroは要素をセマンティクス情報で認識する。Flutterでは`Semantics`ウィジェットでアクセシビリティ情報を提供：

```dart
// ラベルで識別可能にする
Semantics(
  label: 'submit-button',
  child: ElevatedButton(
    onPressed: _submit,
    child: Text('Submit'),
  ),
)

// identifier属性を使用（Flutter 3.19+）
Semantics(
  identifier: 'login-button',
  child: ElevatedButton(...),
)
```

### Maestroでの要素指定

```yaml
# tooltipテキストで認識（FloatingActionButtonなど）
- tapOn: "Increment"

# テキストで認識
- tapOn: "Submit"

# 正規表現
- tapOn:
    text: ".*Login.*"

# identifier使用時（推奨）
- tapOn:
    id: "login-button"
```

### テストファイル構造

```
.maestro/
├── login_test.yaml
├── cart_test.yaml
└── checkout_flow.yaml
```

### 基本的なテスト例

```yaml
appId: com.example.myapp
---
- launchApp
- assertVisible: "Welcome"
- tapOn: "Login"
- inputText:
    id: "email-field"
    text: "test@example.com"
- tapOn: "Submit"
- assertVisible: "Dashboard"
```

## トラブルシューティング

### 要素が見つからない場合

1. `maestro hierarchy` でUI階層を確認
2. Semanticsウィジェットでラベル/識別子を追加
3. テキストマッチングを正規表現に変更

### Flutterウィジェットが認識されない場合

- `Semantics`ウィジェットでラップ
- `excludeSemantics: false`を確認
- `MergeSemantics`で子要素を統合

## ツール使い分けガイド

### 機能比較表

| 機能 | Dart MCP | Maestro MCP |
|------|----------|-------------|
| ウィジェットツリー | ✅ 詳細（Flutter内部） | - |
| アクセシビリティ情報 | - | ✅ accessibilityText |
| スクリーンショット | - | ✅ |
| 要素一覧 | - | ✅ CSV形式 |
| タップ操作 | ⚠️ 要設定 | ✅ テキスト/id指定 |
| ホットリロード | ✅ | - |
| ランタイムエラー | ✅ | - |
| E2Eシナリオ記述 | - | ✅ YAML / 対話的 |

### 推奨される使い分け

**Maestro MCP** (UI操作・確認)
- スクリーンショット取得
- タップ操作（テキスト指定、座標計算不要）
- view hierarchy確認
- E2Eテストシナリオ作成・実行

**Dart MCP** (開発・デバッグ)
- ウィジェットツリーの詳細確認
- ランタイムエラーの取得
- ホットリロード/リスタート
- アプリ起動とDTD接続

### 典型的なワークフロー

```
1. Dart MCP: アプリ起動 → DTD接続
2. Dart MCP: ウィジェットツリーでUI構造確認
3. Maestro MCP: スクリーンショットで視覚確認
4. Maestro MCP: 対話的にタップ操作
5. Maestro CLI: E2Eテストシナリオ作成・実行
6. Dart MCP: エラー時はランタイムエラー確認
```

### Dart MCP flutter_driver使用時

アプリ側に設定が必要：

```dart
// lib/driver_main.dart
import 'package:flutter_driver/driver_extension.dart';
import 'main.dart' as app;

void main() {
  enableFlutterDriverExtension();
  app.main();
}
```

## 参考リンク

- [Maestro Flutter Testing](https://docs.maestro.dev/platform-support/flutter)
- [Mobile MCP](https://github.com/mobile-next/mobile-mcp)
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
