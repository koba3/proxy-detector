# iOS セットアップガイド

このドキュメントは、iOS版プロキシ検出アプリのセットアップと使用方法を説明します。

## 前提条件

- macOS（iOSアプリの開発にはmacOSが必要）
- Xcode 13以上
- Flutter SDK 3.0以上
- CocoaPods（Xcodeインストール時に自動的にインストールされます）

## セットアップ手順

### 1. プロジェクトの準備

```bash
# プロジェクトディレクトリに移動
cd proxy-detector

# 依存関係を取得
flutter pub get

# iOSの依存関係を更新
cd ios
pod install
cd ..
```

### 2. Xcodeでプロジェクトを開く

```bash
open ios/Runner.xcworkspace
```

⚠️ 注意: `Runner.xcodeproj`ではなく、`Runner.xcworkspace`を開いてください。

### 3. 署名の設定

1. Xcodeでプロジェクトを開く
2. 左側のプロジェクトナビゲーターで「Runner」を選択
3. 「Signing & Capabilities」タブを選択
4. 「Team」でApple Developer Teamを選択
5. Bundle Identifierを適切な値に変更（例: `com.yourcompany.proxydetector`）

### 4. シミュレータで実行

```bash
# 利用可能なシミュレータを確認
flutter devices

# iOSシミュレータで実行
flutter run -d "iPhone 14 Pro"
```

### 5. 実機で実行

```bash
# 接続されたデバイスを確認
flutter devices

# 実機で実行
flutter run -d <デバイスID>
```

## iOS プロキシ検出の仕組み

### 使用しているAPI

iOS版では以下のAppleのフレームワークを使用しています：

- **System Configuration framework**: システムのネットワーク設定を取得
- **CFNetwork**: プロキシ設定を取得・解析

### 取得できるプロキシ情報

1. **HTTPプロキシ**
   - ホスト名
   - ポート番号
   - 有効/無効状態

2. **HTTPSプロキシ**
   - ホスト名
   - ポート番号
   - 有効/無効状態

3. **SOCKSプロキシ**
   - ホスト名
   - ポート番号
   - 有効/無効状態

4. **FTPプロキシ**
   - ホスト名
   - ポート番号
   - 有効/無効状態

5. **バイパスリスト**
   - プロキシをバイパスするドメインのリスト

6. **自動設定**
   - 自動検出（WPAD）の有効/無効
   - PAC（Proxy Auto-Configuration）ファイルのURL

### コード例

#### 基本的な使用

```dart
import 'package:proxy_detector/proxy_detector.dart';

Future<void> checkProxy() async {
  // iOS用のリポジトリを作成
  final repository = IOSProxyRepository();
  final service = ProxyService(repository);
  
  // プロキシ設定を取得
  final settings = await service.getProxySettings();
  
  print('プロキシ有効: ${settings.isEnabled}');
  print('プロキシサーバー: ${settings.proxyServer}');
  print('バイパスリスト: ${settings.bypassList}');
  print('自動検出: ${settings.autoDetect}');
  print('自動設定URL: ${settings.autoConfigUrl}');
}
```

#### プラットフォーム自動判定

```dart
import 'package:proxy_detector/proxy_detector.dart';

Future<void> checkProxy() async {
  // プラットフォームを自動判定（iOSまたはWindows）
  final repository = PlatformProxyRepository.create();
  final service = ProxyService(repository);
  
  final settings = await service.getProxySettings();
  
  print('現在のプラットフォーム: ${PlatformProxyRepository.getPlatformName()}');
  print('プロキシ有効: ${settings.isEnabled}');
}
```

#### エラーハンドリング

```dart
import 'package:proxy_detector/proxy_detector.dart';

Future<void> checkProxyWithErrorHandling() async {
  try {
    final service = ProxyService(IOSProxyRepository());
    final settings = await service.getProxySettings();
    
    if (settings.isEnabled) {
      print('プロキシサーバー: ${settings.proxyServer}');
    } else {
      print('プロキシは無効です');
    }
  } on ProxyServiceException catch (e) {
    print('プロキシ設定の取得エラー: ${e.message}');
  } catch (e) {
    print('予期しないエラー: $e');
  }
}
```

## iOSでのプロキシ設定方法

### Wi-Fiプロキシの設定

1. **設定アプリを開く**
2. **Wi-Fi**をタップ
3. 接続中のネットワークの**ⓘ**ボタンをタップ
4. 下にスクロールして**プロキシを構成**をタップ

### 手動プロキシの設定

1. **手動**を選択
2. 以下の情報を入力:
   - **サーバー**: プロキシサーバーのホスト名またはIPアドレス
   - **ポート**: プロキシサーバーのポート番号
   - **認証**: 必要に応じてオン/オフ
   - **ユーザ名**: プロキシの認証ユーザー名（オプション）
   - **パスワード**: プロキシの認証パスワード（オプション）
3. **保存**をタップ

### 自動プロキシの設定

1. **自動**を選択
2. **URL**にPACファイルのURLを入力
   - 例: `http://proxy.example.com/proxy.pac`
3. **保存**をタップ

### プロキシの無効化

1. **オフ**を選択
2. **保存**をタップ

## テスト方法

### ローカルプロキシサーバーのセットアップ

テスト用にローカルプロキシサーバーを起動します：

```bash
# Pythonを使用した簡易プロキシサーバー
# Python 3がインストールされている必要があります
python3 -m http.server 8080
```

または、専用のプロキシツールを使用：

- **Charles Proxy**: https://www.charlesproxy.com/
- **mitmproxy**: https://mitmproxy.org/

### iOS設定

1. Macのローカルプロキシサーバーを起動
2. MacのIPアドレスを確認（システム環境設定 > ネットワーク）
3. iOSデバイスで以下を設定:
   - サーバー: MacのIPアドレス（例: `192.168.1.10`）
   - ポート: `8080`

### アプリで確認

1. プロキシ検出アプリを起動
2. プロキシ設定が正しく表示されることを確認

## トラブルシューティング

### ビルドエラー

#### エラー: "Could not find module 'Flutter'"

**解決方法**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

#### エラー: "Code signing is required"

**解決方法**:
1. Xcodeでプロジェクトを開く
2. 「Signing & Capabilities」でTeamを選択
3. Bundle Identifierを変更

### プロキシ設定が取得できない

#### シミュレータでプロキシが検出されない

**原因**: iOSシミュレータはMacのプロキシ設定を継承しません。

**解決方法**:
1. シミュレータで「設定」アプリを開く
2. Wi-Fi設定からプロキシを手動で設定

#### 実機でプロキシが検出されない

**確認事項**:
1. Wi-Fiに接続されているか確認
2. プロキシ設定が正しく設定されているか確認
3. アプリを再起動

### パフォーマンス問題

プロキシ設定の取得が遅い場合:

```dart
// キャッシュを使用
import 'package:proxy_detector/proxy_detector.dart';

class CachedIOSProxyRepository implements ProxyRepository {
  final IOSProxyRepository _inner = IOSProxyRepository();
  ProxySettings? _cache;
  DateTime? _cacheTime;
  
  @override
  Future<ProxySettings> getProxySettings() async {
    if (_cache != null && 
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < Duration(minutes: 5)) {
      return _cache!;
    }
    
    _cache = await _inner.getProxySettings();
    _cacheTime = DateTime.now();
    return _cache!;
  }
  
  // ... 他のメソッド
}
```

## iOS固有の機能

### 特定のURLに対するプロキシ設定

iOS版では、特定のURLに対するプロキシ設定を取得できます：

```swift
// ネイティブコード（ProxyDetector.swift）
let proxyInfo = ProxyDetector.getProxyForURL("https://example.com")
```

### 詳細なプロキシ情報

HTTP、HTTPS、SOCKS、FTPの詳細情報を個別に取得できます：

```swift
// ネイティブコード（ProxyDetector.swift）
let details = ProxyDetector.getDetailedProxySettings()
// details["http"], details["https"], details["socks"], details["ftp"]
```

## リソース

- [Apple Developer - System Configuration](https://developer.apple.com/documentation/systemconfiguration)
- [Apple Developer - CFNetwork](https://developer.apple.com/documentation/cfnetwork)
- [Flutter iOS Documentation](https://docs.flutter.dev/deployment/ios)

## まとめ

iOS版プロキシ検出機能により：

- ✅ iOSデバイスのプロキシ設定を自動検出
- ✅ HTTP、HTTPS、SOCKS、FTPプロキシに対応
- ✅ 自動設定（WPAD、PAC）をサポート
- ✅ Windowsと同じインターフェースで利用可能
- ✅ プラットフォーム自動判定で簡単に切り替え

Windows版と組み合わせることで、マルチプラットフォーム対応のプロキシ検出ライブラリとして活用できます！

