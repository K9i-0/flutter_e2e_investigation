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

## 参考リンク

- [Maestro Flutter Testing](https://docs.maestro.dev/platform-support/flutter)
- [Mobile MCP](https://github.com/mobile-next/mobile-mcp)
- [Dart MCP Server](https://github.com/dart-lang/ai/tree/main/pkgs/dart_mcp_server)
