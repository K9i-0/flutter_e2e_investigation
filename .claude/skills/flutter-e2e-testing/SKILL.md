---
name: flutter-e2e-testing
description: FlutterアプリのE2Eテストとモバイル自動化の知見。Maestro、Mobile MCP、Dart MCPを使用したテスト作成・実行時に使用。
---

# Flutter E2E Testing

## ツール概要

### Maestro
- Flutter第一級サポートのE2Eテストフレームワーク
- YAMLでテストを記述
- `maestro test .maestro/test.yaml` で実行

### Mobile MCP
- AIエージェントからモバイルアプリを操作するMCPサーバー
- スクリーンショット、タップ、スワイプなどの操作が可能
- ネイティブアプリ向けだがFlutterでも動作

### Dart MCP Server
- Flutter開発連携用MCPサーバー
- ホットリロード、ウィジェットツリー取得などが可能

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

| 機能 | Dart MCP | Mobile MCP | Maestro |
|------|----------|------------|---------|
| ウィジェットツリー | ✅ 詳細 | - | - |
| アクセシビリティ情報 | - | ✅ label属性 | ✅ accessibilityText |
| スクリーンショット | - | ✅ | ✅ |
| 座標付き要素一覧 | - | ✅ | ✅ (JSON) |
| タップ操作 | ⚠️ 要設定 | ✅ 座標指定 | ✅ テキスト/id指定 |
| ホットリロード | ✅ | - | - |
| ランタイムエラー | ✅ | - | - |
| E2Eシナリオ記述 | - | - | ✅ YAML |

### 推奨される使い分け

**Maestro** (E2Eテスト向け)
- UI操作とアサーション
- アクセシビリティ情報の取得（`maestro hierarchy`）
- テストシナリオの記述と再利用
- CI/CD連携

**Dart MCP** (開発・デバッグ向け)
- ウィジェットツリーの詳細確認
- ランタイムエラーの取得
- ホットリロード/リスタート
- アプリ起動とDTD接続

**Mobile MCP** (対話的操作向け)
- Claude Codeからの即座のUI確認
- スクリーンショット取得
- 座標ベースのタップ操作（要素中心を計算）

### 典型的なワークフロー

```
1. Dart MCP: アプリ起動 → DTD接続
2. Dart MCP: ウィジェットツリーでUI構造確認
3. Mobile MCP: スクリーンショットで視覚確認
4. Maestro: E2Eテストシナリオ作成・実行
5. Dart MCP: エラー時はランタイムエラー確認
```

### Mobile MCP タップ時の注意

`list_elements_on_screen`の座標は要素の**左上**。中心をタップするには：

```
center_x = x + width / 2
center_y = y + height / 2
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
