# プラットフォームサポート状況

このドキュメントは、プロキシ検出アプリの各プラットフォームでのサポート状況を説明します。

## サポート状況一覧

| プラットフォーム | 対応状況 | 最小バージョン | 実装方法 | セットアップガイド |
|----------------|---------|---------------|---------|-------------------|
| **Windows** | ✅ 完全対応 | Windows 10/11 | WinHTTP API | README.md |
| **iOS** | ✅ 完全対応 | iOS 12以降 | System Configuration framework | IOS_SETUP.md |
| **Android** | ✅ 完全対応 | Android 5.0 (API 21) | ConnectivityManager | ANDROID_SETUP.md |
| **macOS** | ⚠️ 未実装 | macOS 10.15以降 | iOS実装を参考に可能 | - |
| **Linux** | ⚠️ 未実装 | - | 環境変数から取得可能 | - |
| **Web** | ❌ 非対応 | - | ブラウザ制限により困難 | - |

## プラットフォーム別詳細

### ✅ Windows (完全対応)

#### サポート情報
- **最小バージョン**: Windows 10/11
- **開発環境**: Visual Studio 2019以降
- **使用API**: WinHTTP API
- **言語**: C++

#### 取得できる情報
- ✅ HTTPプロキシ
- ✅ HTTPSプロキシ
- ✅ プロキシサーバー（ホスト:ポート）
- ✅ バイパスリスト
- ✅ 自動検出（WPAD）
- ✅ 自動設定URL（PAC）

#### 実装ファイル
- `lib/repositories/windows_proxy_repository.dart`
- `windows/runner/proxy_detector.h/cpp`
- `windows/runner/flutter_window.cpp`

#### セットアップ
詳細は [README.md](README.md) を参照

---

### ✅ iOS (完全対応)

#### サポート情報
- **最小バージョン**: iOS 12以降（推奨: iOS 13以降）
- **開発環境**: Xcode 13以降、macOS
- **使用API**: System Configuration framework, CFNetwork
- **言語**: Swift

#### 取得できる情報
- ✅ HTTPプロキシ
- ✅ HTTPSプロキシ
- ✅ SOCKSプロキシ
- ✅ FTPプロキシ
- ✅ プロキシサーバー（ホスト:ポート）
- ✅ バイパスリスト
- ✅ 自動検出（WPAD）
- ✅ 自動設定URL（PAC）
- ✅ 特定URLに対するプロキシ設定

#### 実装ファイル
- `lib/repositories/ios_proxy_repository.dart`
- `ios/Runner/ProxyDetector.swift`
- `ios/Runner/AppDelegate.swift`

#### セットアップ
詳細は [IOS_SETUP.md](IOS_SETUP.md) を参照

---

### ✅ Android (完全対応)

#### サポート情報
- **最小バージョン**: Android 5.0 (Lollipop, API 21)
- **推奨バージョン**: Android 6.0 (Marshmallow, API 23) 以降
- **開発環境**: Android Studio、Android SDK
- **使用API**: ConnectivityManager, LinkProperties, ProxyInfo
- **言語**: Kotlin

#### 取得できる情報
- ✅ HTTPプロキシ
- ✅ プロキシサーバー（ホスト:ポート）
- ✅ バイパスリスト（除外リスト）
- ✅ 自動設定URL（PAC） ※Android 5.0以降
- ✅ ネットワーク接続状態（Wi-Fi/モバイルデータ）
- ⚠️ Wi-Fi接続時のみプロキシ設定取得可能

#### 実装ファイル
- `lib/repositories/android_proxy_repository.dart`
- `android/app/src/main/kotlin/com/example/proxy_detector/ProxyDetector.kt`
- `android/app/src/main/kotlin/com/example/proxy_detector/MainActivity.kt`

#### セットアップ
詳細は [ANDROID_SETUP.md](ANDROID_SETUP.md) を参照

---

### ⚠️ macOS (未実装・実装可能)

#### 実装の可能性
macOSはiOSと同じSystem Configuration frameworkを使用できるため、iOS実装を参考にすることで実装可能です。

#### 実装方法
1. `lib/repositories/macos_proxy_repository.dart`を作成
2. `ios/Runner/ProxyDetector.swift`を参考にSwiftコードを作成
3. `macos/Runner/MainFlutterWindow.swift`でメソッドチャンネルを設定

#### 使用可能なAPI
- System Configuration framework
- CFNetwork
- `SCDynamicStoreCopyProxies`関数

#### コード例（macOS実装の参考）
```swift
import Foundation
import SystemConfiguration

class MacOSProxyDetector {
    static func getSystemProxySettings() -> [String: Any] {
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return [:]
        }
        
        // iOS実装と同様の処理
        // ...
    }
}
```

---

### ⚠️ Linux (未実装・実装可能)

#### 実装の可能性
Linuxでは環境変数やGNOME設定から プロキシ情報を取得できます。

#### 実装方法

##### 方法1: 環境変数から取得（推奨）

```dart
import 'dart:io';

class LinuxProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    final httpProxy = Platform.environment['HTTP_PROXY'] ?? 
                      Platform.environment['http_proxy'] ?? '';
    final httpsProxy = Platform.environment['HTTPS_PROXY'] ?? 
                       Platform.environment['https_proxy'] ?? '';
    final noProxy = Platform.environment['NO_PROXY'] ?? 
                    Platform.environment['no_proxy'] ?? '';
    
    final isEnabled = httpProxy.isNotEmpty || httpsProxy.isNotEmpty;
    final proxyServer = httpProxy.isNotEmpty ? httpProxy : httpsProxy;
    
    return ProxySettings(
      isEnabled: isEnabled,
      proxyServer: _parseProxyUrl(proxyServer),
      bypassList: noProxy,
      autoDetect: false,
      autoConfigUrl: '',
    );
  }
  
  String _parseProxyUrl(String url) {
    // http://proxy:8080 -> proxy:8080
    return url.replaceFirst(RegExp(r'https?://'), '');
  }
}
```

##### 方法2: GNOME設定から取得

```bash
# コマンドライン経由で取得
gsettings get org.gnome.system.proxy mode
gsettings get org.gnome.system.proxy.http host
gsettings get org.gnome.system.proxy.http port
```

#### 環境変数一覧
- `HTTP_PROXY` / `http_proxy`: HTTPプロキシ
- `HTTPS_PROXY` / `https_proxy`: HTTPSプロキシ
- `FTP_PROXY` / `ftp_proxy`: FTPプロキシ
- `NO_PROXY` / `no_proxy`: バイパスリスト
- `ALL_PROXY` / `all_proxy`: すべてのプロトコルのプロキシ

---

### ❌ Web (非対応)

#### 非対応の理由
Webブラウザのセキュリティ制限により、JavaScriptからシステムのプロキシ設定を取得することはできません。

#### 代替案
1. **サーバーサイドで取得**: バックエンドサーバーでプロキシ設定を管理
2. **ユーザー入力**: ユーザーに手動でプロキシ設定を入力してもらう
3. **ブラウザ拡張機能**: Chrome ExtensionやFirefox Add-onとして実装

#### Web用カスタムリポジトリ例

```dart
class WebProxyRepository implements ProxyRepository {
  final String? userInputProxy;
  
  WebProxyRepository({this.userInputProxy});
  
  @override
  Future<ProxySettings> getProxySettings() async {
    if (userInputProxy != null && userInputProxy!.isNotEmpty) {
      return ProxySettings(
        isEnabled: true,
        proxyServer: userInputProxy!,
        bypassList: '',
        autoDetect: false,
        autoConfigUrl: '',
      );
    }
    
    return ProxySettings.empty();
  }
}
```

---

## プラットフォーム自動判定

`PlatformProxyRepository.create()`を使用することで、実行中のプラットフォームに応じて自動的に適切なリポジトリを選択できます。

### 使用例

```dart
import 'package:proxy_detector/proxy_detector.dart';

void main() async {
  // プラットフォームを確認
  print('プラットフォーム: ${PlatformProxyRepository.getPlatformName()}');
  print('サポート状況: ${PlatformProxyRepository.isSupported()}');
  
  // サポートされているプラットフォームのみで実行
  if (PlatformProxyRepository.isSupported()) {
    final repository = PlatformProxyRepository.create();
    final service = ProxyService(repository);
    
    final settings = await service.getProxySettings();
    print('プロキシ: ${settings.proxyServer}');
  } else {
    print('このプラットフォームはサポートされていません');
  }
}
```

### サポート判定

```dart
PlatformProxyRepository.isSupported() // true or false
PlatformProxyRepository.getPlatformName() // "Windows", "iOS", "Android", etc.
```

---

## 機能比較表

| 機能 | Windows | iOS | Android | macOS | Linux |
|------|---------|-----|---------|-------|-------|
| HTTPプロキシ | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| HTTPSプロキシ | ✅ | ✅ | ⚠️ | ⚠️ | ⚠️ |
| SOCKSプロキシ | ❌ | ✅ | ❌ | ⚠️ | ⚠️ |
| FTPプロキシ | ❌ | ✅ | ❌ | ⚠️ | ⚠️ |
| バイパスリスト | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| 自動検出（WPAD） | ✅ | ✅ | ❌ | ⚠️ | ❌ |
| PAC URL | ✅ | ✅ | ✅ | ⚠️ | ⚠️ |
| 特定URL用プロキシ | ❌ | ✅ | ❌ | ⚠️ | ❌ |
| リアルタイム更新 | ❌ | ❌ | ⚠️ | ⚠️ | ⚠️ |

凡例:
- ✅ = 完全対応
- ⚠️ = 部分対応または未実装だが実装可能
- ❌ = 非対応

---

## 開発ロードマップ

### Phase 1: 完了済み ✅
- [x] Windows実装
- [x] iOS実装
- [x] Android実装
- [x] プラットフォーム自動判定
- [x] 疎結合アーキテクチャ

### Phase 2: 今後の予定
- [ ] macOS実装
- [ ] Linux実装（環境変数ベース）
- [ ] リアルタイムプロキシ変更監視
- [ ] プロキシ認証情報の取得

### Phase 3: 拡張機能
- [ ] プロキシ接続テスト機能
- [ ] プロキシパフォーマンス測定
- [ ] プロキシ設定の保存/復元
- [ ] プロキシ設定の比較機能

---

## コントリビューション

新しいプラットフォームの実装やバグ修正のコントリビューションを歓迎します！

### 新しいプラットフォームを追加する手順

1. **リポジトリを作成**: `lib/repositories/<platform>_proxy_repository.dart`
2. **ネイティブコードを実装**: プラットフォーム固有のディレクトリに配置
3. **メソッドチャンネルを設定**: Flutter ↔ ネイティブの通信を実装
4. **`platform_proxy_repository.dart`を更新**: 自動判定に追加
5. **テストを追加**: ユニットテストと統合テストを作成
6. **ドキュメントを作成**: セットアップガイドを作成

### テンプレート

新しいプラットフォームのリポジトリテンプレート:

```dart
import 'package:flutter/services.dart';
import '../models/proxy_settings.dart';
import 'proxy_repository.dart';

class YourPlatformProxyRepository implements ProxyRepository {
  final MethodChannel _channel;

  YourPlatformProxyRepository({String channelName = 'proxy_detector'})
      : _channel = MethodChannel(channelName);

  @override
  Future<ProxySettings> getProxySettings() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getProxySettings');
      return ProxySettings.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw ProxyRepositoryException('取得失敗', e);
    }
  }

  @override
  Future<bool> isProxyEnabled() async {
    // 実装
  }

  @override
  Future<String> getProxyServer() async {
    // 実装
  }
}
```

---

## まとめ

現在、**Windows、iOS、Android**の3つの主要プラットフォームで完全に動作するプロキシ検出機能を提供しています。

- ✅ **マルチプラットフォーム**: 3つのOSで動作
- ✅ **疎結合設計**: 他のプロジェクトで再利用可能
- ✅ **プラットフォーム自動判定**: コードを変更せずに動作
- ✅ **包括的なドキュメント**: 各プラットフォームのセットアップガイド完備

macOSとLinuxの実装も技術的に可能で、コントリビューションを歓迎します！

