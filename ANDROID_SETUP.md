# Android セットアップガイド

このドキュメントは、Android版プロキシ検出アプリのセットアップと使用方法を説明します。

## 前提条件

- Flutter SDK 3.0以上
- Android Studio
- Android SDK (API 21以上)
- Java Development Kit (JDK) 11以上

## セットアップ手順

### 1. プロジェクトの準備

```bash
# プロジェクトディレクトリに移動
cd proxy-detector

# 依存関係を取得
flutter pub get
```

### 2. Android Studioでプロジェクトを開く

```bash
# Android Studioでandroidディレクトリを開く
cd android
# または Android Studio から android ディレクトリを開く
```

### 3. エミュレータで実行

```bash
# 利用可能なエミュレータを確認
flutter emulators

# エミュレータを起動
flutter emulators --launch <エミュレータID>

# アプリを実行
flutter run -d android
```

### 4. 実機で実行

```bash
# USBデバッグを有効にしたAndroidデバイスを接続

# 接続されたデバイスを確認
flutter devices

# 実機で実行
flutter run -d <デバイスID>
```

## Android プロキシ検出の仕組み

### 使用しているAPI

Android版では以下のAndroid APIを使用しています：

- **ConnectivityManager**: ネットワーク接続状態を管理
- **LinkProperties**: ネットワークリンクのプロパティ（プロキシ設定を含む）を取得
- **ProxyInfo**: プロキシ設定情報を格納

### 対応Androidバージョン

- **Android 5.0 (Lollipop, API 21)** 以降をサポート
- **Android 6.0 (Marshmallow, API 23)** 以降で最適な動作
- PAC（Proxy Auto-Configuration）は **Android 5.0 (API 21)** 以降で対応

### 取得できるプロキシ情報

1. **プロキシホスト**
   - プロキシサーバーのホスト名またはIPアドレス

2. **プロキシポート**
   - プロキシサーバーのポート番号

3. **除外リスト（バイパスリスト）**
   - プロキシを使用しないドメインやIPアドレスのリスト

4. **PAC URL**
   - プロキシ自動設定ファイル（PAC）のURL

5. **ネットワーク情報**
   - Wi-Fi接続状態
   - モバイルデータ接続状態
   - インターネット接続可否

### コード例

#### 基本的な使用

```dart
import 'package:proxy_detector/proxy_detector.dart';

Future<void> checkProxy() async {
  // Android用のリポジトリを作成
  final repository = AndroidProxyRepository();
  final service = ProxyService(repository);
  
  // プロキシ設定を取得
  final settings = await service.getProxySettings();
  
  print('プロキシ有効: ${settings.isEnabled}');
  print('プロキシサーバー: ${settings.proxyServer}');
  print('バイパスリスト: ${settings.bypassList}');
  print('自動設定URL: ${settings.autoConfigUrl}');
}
```

#### プラットフォーム自動判定

```dart
import 'package:proxy_detector/proxy_detector.dart';

Future<void> checkProxy() async {
  // プラットフォームを自動判定（Windows、iOS、またはAndroid）
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
    final service = ProxyService(AndroidProxyRepository());
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

## Androidでのプロキシ設定方法

### Wi-Fiプロキシの設定

#### 手動プロキシ設定

1. **設定アプリを開く**
2. **Wi-Fi**をタップ
3. 接続中のネットワークを**長押し**
4. **ネットワークを変更**をタップ
5. **詳細オプション**を展開
6. **プロキシ**: **手動**を選択
7. 以下の情報を入力:
   - **プロキシホスト名**: プロキシサーバーのホスト名またはIPアドレス
   - **プロキシポート**: プロキシサーバーのポート番号
   - **プロキシのバイパス**: プロキシを使用しないドメイン（カンマ区切り）
8. **保存**をタップ

#### 自動プロキシ設定（PAC）

1. 上記手順の1-5を実行
2. **プロキシ**: **プロキシ自動設定**を選択
3. **PAC URL**にPACファイルのURLを入力
   - 例: `http://proxy.example.com/proxy.pac`
4. **保存**をタップ

#### プロキシの無効化

1. 上記手順の1-5を実行
2. **プロキシ**: **なし**を選択
3. **保存**をタップ

### Android バージョン別の違い

#### Android 5.x - 6.x (API 21-23)

- 基本的なHTTPプロキシ設定をサポート
- Wi-Fi接続のみプロキシ設定可能
- システムプロパティからプロキシ情報を取得

#### Android 7.0以降 (API 24+)

- PAC（Proxy Auto-Configuration）の完全サポート
- より詳細なプロキシ情報を取得可能
- 複数のネットワークインターフェースに対応

#### Android 10以降 (API 29+)

- プライバシー強化によりプロキシ情報の取得に制限
- Wi-Fi接続時のプロキシ設定は引き続き取得可能

## テスト方法

### ローカルプロキシサーバーのセットアップ

開発用PCでプロキシサーバーを起動:

```bash
# Python 3を使用した簡易HTTPサーバー
python3 -m http.server 8080

# または専用プロキシツールを使用
# - Charles Proxy
# - mitmproxy
# - Squid
```

### Android設定

1. PCとAndroidデバイスを同じネットワークに接続
2. PCのIPアドレスを確認
3. Androidデバイスで以下を設定:
   - プロキシホスト名: PCのIPアドレス（例: `192.168.1.10`）
   - プロキシポート: `8080`

### アプリで確認

1. プロキシ検出アプリを起動
2. プロキシ設定が正しく表示されることを確認

## 必要な権限

アプリは以下の権限を使用します（`AndroidManifest.xml`に記載）：

```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 権限の説明

- **ACCESS_NETWORK_STATE**: ネットワーク接続状態とプロキシ設定を取得するために必要
- **INTERNET**: ネットワーク情報にアクセスするために必要

これらは**通常の権限**であり、ユーザーの承認は不要です。

## トラブルシューティング

### ビルドエラー

#### エラー: "Gradle sync failed"

**解決方法**:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### エラー: "Minimum SDK version"

**原因**: アプリはAndroid API 21以降が必要です。

**解決方法**: `android/app/build.gradle.kts`を確認:
```kotlin
android {
    defaultConfig {
        minSdk = 21  // 21以上であることを確認
    }
}
```

### プロキシ設定が取得できない

#### エミュレータでプロキシが検出されない

**原因**: Androidエミュレータは独自のネットワーク設定を使用します。

**解決方法**:
1. エミュレータの設定を開く
2. 「Extended controls」（...ボタン）を開く
3. 「Settings」 > 「Proxy」でプロキシを設定

#### 実機でプロキシが検出されない

**確認事項**:
1. Wi-Fiに接続されているか確認
2. プロキシ設定が正しく設定されているか確認
3. Android 10以降の場合、アプリのターゲットSDKを確認
4. アプリを再起動

#### プロキシ情報が空

**原因**: 
- プロキシが設定されていない
- モバイルデータ接続を使用している（プロキシ設定はWi-Fi接続のみ）

**解決方法**:
- Wi-Fi接続を使用
- Wi-Fiネットワークのプロキシ設定を確認

### パフォーマンス問題

プロキシ設定の取得が遅い場合、キャッシュを使用:

```dart
import 'package:proxy_detector/proxy_detector.dart';

class CachedAndroidProxyRepository implements ProxyRepository {
  final AndroidProxyRepository _inner = AndroidProxyRepository();
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

## Android固有の機能

### 詳細なネットワーク情報

Android版では、プロキシ設定に加えて以下の情報も取得できます：

```kotlin
// ネイティブコード（ProxyDetector.kt）
val details = proxyDetector.getDetailedProxySettings()
// details["hasInternet"]   - インターネット接続の可否
// details["hasWifi"]       - Wi-Fi接続の有無
// details["hasCellular"]   - モバイルデータ接続の有無
```

### プロキシ設定の監視

ネットワーク状態の変化を監視する場合:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class ProxyMonitor {
  final ProxyService _service;
  
  ProxyMonitor(this._service);
  
  void startMonitoring() {
    Connectivity().onConnectivityChanged.listen((result) async {
      if (result != ConnectivityResult.none) {
        // ネットワーク接続が変わったらプロキシ設定を再取得
        final settings = await _service.getProxySettings();
        print('プロキシ設定更新: ${settings.proxyServer}');
      }
    });
  }
}
```

注意: `connectivity_plus`パッケージを`pubspec.yaml`に追加する必要があります。

## リソース

- [Android Developer - ConnectivityManager](https://developer.android.com/reference/android/net/ConnectivityManager)
- [Android Developer - LinkProperties](https://developer.android.com/reference/android/net/LinkProperties)
- [Android Developer - ProxyInfo](https://developer.android.com/reference/android/net/ProxyInfo)
- [Flutter Android Documentation](https://docs.flutter.dev/deployment/android)

## まとめ

Android版プロキシ検出機能により：

- ✅ Androidデバイスのプロキシ設定を自動検出
- ✅ Wi-Fi接続時のHTTPプロキシに対応
- ✅ PAC（Proxy Auto-Configuration）をサポート
- ✅ Android 5.0 (API 21) 以降をサポート
- ✅ Windows、iOSと同じインターフェースで利用可能
- ✅ プラットフォーム自動判定で簡単に切り替え

Windows、iOSと組み合わせることで、完全なマルチプラットフォーム対応のプロキシ検出ライブラリとして活用できます！

