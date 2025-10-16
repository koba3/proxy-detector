# Windows プロキシ設定検出アプリ

このFlutterアプリは、Windowsシステムのプロキシ設定を検出して表示するテストアプリケーションです。

## 機能

- Windowsシステムのプロキシ設定を自動検出
- プロキシサーバー情報の表示
- バイパスリストの表示
- 自動設定URLの表示
- プロキシ有効/無効状態の確認

## 使用方法

### 前提条件

- Flutter SDK (3.0以上)
- Windows 10/11
- Visual Studio 2019以上（Windows開発用）

### ビルドと実行

1. プロジェクトディレクトリに移動
```bash
cd proxy_detector
```

2. 依存関係を取得
```bash
flutter pub get
```

3. Windowsでアプリを実行
```bash
flutter run -d windows
```

### テスト用プロキシ設定

アプリをテストするために、以下のプロキシ設定を試すことができます：

#### 1. 手動プロキシ設定
- Windows設定 > ネットワークとインターネット > プロキシ
- 「手動プロキシ設定をオンにする」を有効
- プロキシサーバー: `127.0.0.1:8080`
- バイパスリスト: `localhost;127.0.0.1`

#### 2. 自動設定
- 「設定を自動的に検出する」を有効
- または「セットアップスクリプトを使用する」を有効

#### 3. プロキシ無効
- 「プロキシサーバーを使用しない」を選択

## アーキテクチャ

### ネイティブコード (C++)
- `proxy_detector.h/cpp`: Windows APIを使用してプロキシ設定を取得
- WinHTTP APIを使用してIEプロキシ設定を読み取り

### Flutter側
- `proxy_service.dart`: ネイティブコードとの通信を管理
- `main.dart`: UIとプロキシ設定の表示

### メソッドチャンネル
- `getProxySettings`: 全プロキシ設定を取得
- `isProxyEnabled`: プロキシ有効状態を確認
- `getProxyServer`: プロキシサーバー情報を取得

## トラブルシューティング

### ビルドエラー
- Visual StudioのC++開発ツールがインストールされていることを確認
- Windows SDKが最新版であることを確認

### プロキシ設定が取得できない
- 管理者権限でアプリを実行してみる
- Windowsのプロキシ設定が正しく設定されていることを確認

## 開発者向け情報

### 新しい機能の追加
1. `proxy_detector.cpp`でネイティブ機能を実装
2. `flutter_window.cpp`でメソッドチャンネルにハンドラーを追加
3. `proxy_service.dart`でDart側のインターフェースを追加
4. `main.dart`でUIを更新

### デバッグ
- Visual Studioでネイティブコードをデバッグ可能
- Flutter DevToolsでUIをデバッグ可能