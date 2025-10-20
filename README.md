# プロキシ設定検出アプリ (Windows, iOS & Android)

このFlutterアプリは、Windows、iOS、Android のシステムプロキシ設定を検出して表示するマルチプラットフォームアプリケーションです。

## 機能

- **マルチプラットフォーム対応**: Windows、iOS、Android でプロキシ設定を自動検出
- プロキシサーバー情報の表示
- バイパスリストの表示
- 自動設定URLの表示
- プロキシ有効/無効状態の確認
- プラットフォーム自動判定機能
- Android 5.0 (API 21) 以降をサポート

## 使用方法

### 前提条件

- Flutter SDK (3.0以上)
- **Windows開発**: Windows 10/11、Visual Studio 2019以上
- **iOS開発**: macOS、Xcode 13以上
- **Android開発**: Android Studio、Android SDK (API 21以上)

### ビルドと実行

1. プロジェクトディレクトリに移動
```bash
cd proxy_detector
```

2. 依存関係を取得
```bash
flutter pub get
```

3. アプリを実行

Windowsで実行:
```bash
flutter run -d windows
```

iOSシミュレータで実行:
```bash
flutter run -d ios
```

実機のiOSデバイスで実行:
```bash
flutter run -d <デバイスID>
```

Androidエミュレータで実行:
```bash
flutter run -d android
```

実機のAndroidデバイスで実行:
```bash
flutter run -d <デバイスID>
```

### テスト用プロキシ設定

アプリをテストするために、以下のプロキシ設定を試すことができます：

#### Windows
1. **手動プロキシ設定**
   - Windows設定 > ネットワークとインターネット > プロキシ
   - 「手動プロキシ設定をオンにする」を有効
   - プロキシサーバー: `127.0.0.1:8080`
   - バイパスリスト: `localhost;127.0.0.1`

2. **自動設定**
   - 「設定を自動的に検出する」を有効
   - または「セットアップスクリプトを使用する」を有効

3. **プロキシ無効**
   - 「プロキシサーバーを使用しない」を選択

#### iOS
1. **手動プロキシ設定**
   - 設定 > Wi-Fi > 接続中のネットワーク > プロキシを構成
   - 「手動」を選択
   - サーバー: `127.0.0.1`、ポート: `8080`

2. **自動設定**
   - 「自動」を選択
   - URL: プロキシ自動設定ファイル（PAC）のURL

3. **プロキシ無効**
   - 「オフ」を選択

#### Android
1. **手動プロキシ設定**
   - 設定 > Wi-Fi > 接続中のネットワークを長押し > ネットワークを変更
   - 「詳細オプション」を表示
   - プロキシ: 「手動」を選択
   - プロキシホスト名: `127.0.0.1`、ポート: `8080`

2. **自動設定（PAC）**
   - プロキシ: 「プロキシ自動設定」を選択
   - PAC URL: プロキシ自動設定ファイルのURL

3. **プロキシ無効**
   - プロキシ: 「なし」を選択

## アーキテクチャ

このプロジェクトは、**疎結合で再利用可能な設計**を採用しています。プロキシ検出ロジックは他のプロジェクトでも簡単に再利用できます。

### レイヤー構造

```
┌─────────────────────────────────────┐
│  UI Layer (main.dart)               │
│  - プロキシ設定の表示               │
│  - ユーザーインタラクション         │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Service Layer (proxy_service.dart) │
│  - ビジネスロジック                 │
│  - データ変換・検証                 │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Repository Layer                   │
│  - プラットフォーム抽象化           │
│  - ProxyRepository (インターフェース)│
│  - WindowsProxyRepository (実装)    │
└─────────────────────────────────────┘
              ↓
┌─────────────────────────────────────┐
│  Model Layer (proxy_settings.dart)  │
│  - データモデル                     │
│  - プラットフォーム非依存           │
└─────────────────────────────────────┘
```

### コンポーネント

#### 1. Models (`lib/models/`)
- **`proxy_settings.dart`**: プロキシ設定のデータモデル
  - プラットフォーム非依存
  - イミュータブル（不変）
  - シリアライズ/デシリアライズ対応

#### 2. Repositories (`lib/repositories/`)
- **`proxy_repository.dart`**: プロキシリポジトリのインターフェース
  - 抽象化層として機能
  - 異なる実装を切り替え可能
- **`windows_proxy_repository.dart`**: Windows実装
  - WinHTTP APIを使用
  - MethodChannelでネイティブコードと通信
- **`ios_proxy_repository.dart`**: iOS実装
  - System Configuration frameworkを使用
  - CFNetworkでプロキシ設定を取得
- **`android_proxy_repository.dart`**: Android実装
  - ConnectivityManagerを使用
  - LinkPropertiesからプロキシ設定を取得
- **`platform_proxy_repository.dart`**: プラットフォーム自動判定
  - 現在のプラットフォームに応じて適切なリポジトリを自動選択

#### 3. Services (`lib/services/`)
- **`proxy_service.dart`**: ビジネスロジック層
  - リポジトリを通じてデータを取得
  - 依存性注入によりテスト可能
  - 追加のビジネスロジックを提供

#### 4. Native Code
**Windows** (`windows/runner/`):
- **`proxy_detector.h/cpp`**: Windows APIを使用してプロキシ設定を取得
- **`flutter_window.cpp`**: MethodChannelハンドラー
- WinHTTP APIを使用してIEプロキシ設定を読み取り

**iOS** (`ios/Runner/`):
- **`ProxyDetector.swift`**: System Configuration frameworkを使用
- **`AppDelegate.swift`**: MethodChannelハンドラー
- CFNetworkでプロキシ設定を取得（HTTP、HTTPS、SOCKS、FTP対応）

**Android** (`android/app/src/main/kotlin/`):
- **`ProxyDetector.kt`**: ConnectivityManagerとLinkPropertiesを使用
- **`MainActivity.kt`**: MethodChannelハンドラー
- Android 5.0 (API 21) 以降をサポート

### 他のプロジェクトでの使用方法

このライブラリは疎結合に設計されているため、簡単に他のプロジェクトで再利用できます。

#### 基本的な使用例

```dart
import 'package:proxy_detector/proxy_detector.dart';

// 方法1: プラットフォーム自動判定（推奨）
final repository = PlatformProxyRepository.create(); // Windows, iOS, Android を自動選択
final proxyService = ProxyService(repository);

// 方法2: 特定のプラットフォームを指定
// final repository = WindowsProxyRepository();  // Windows専用
// final repository = IOSProxyRepository();      // iOS専用
// final repository = AndroidProxyRepository();  // Android専用

// プロキシ設定を取得
final settings = await proxyService.getProxySettings();
print('プロキシ有効: ${settings.isEnabled}');
print('サーバー: ${settings.proxyServer}');
```

#### カスタムリポジトリの実装

```dart
// 独自のプロキシ検出ロジックを実装
class CustomProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    // カスタムロジックを実装
    return ProxySettings(...);
  }
  
  @override
  Future<bool> isProxyEnabled() async { ... }
  
  @override
  Future<String> getProxyServer() async { ... }
}

// カスタムリポジトリを使用
final service = ProxyService(CustomProxyRepository());
```

#### テスト用モックの使用

```dart
class MockProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    return ProxySettings(
      isEnabled: true,
      proxyServer: 'test-proxy:8080',
      bypassList: 'localhost',
      autoDetect: false,
      autoConfigUrl: '',
    );
  }
  // ... 他のメソッド
}

// テストで使用
final mockService = ProxyService(MockProxyRepository());
```

詳細な使用例は `example/proxy_detector_example.dart` を参照してください。

### メソッドチャンネル

**共通メソッド** (Windows, iOS & Android):
- `getProxySettings`: 全プロキシ設定を取得
- `isProxyEnabled`: プロキシ有効状態を確認
- `getProxyServer`: プロキシサーバー情報を取得

**iOS専用メソッド**:
- `getDetailedProxySettings`: HTTP、HTTPS、SOCKS、FTPの詳細情報を取得
- `getProxyForURL`: 特定のURLに対するプロキシ設定を取得

**Android専用メソッド**:
- `getDetailedProxySettings`: プロキシとネットワーク接続の詳細情報を取得

## トラブルシューティング

### ビルドエラー
- Visual StudioのC++開発ツールがインストールされていることを確認
- Windows SDKが最新版であることを確認

### プロキシ設定が取得できない
- 管理者権限でアプリを実行してみる
- Windowsのプロキシ設定が正しく設定されていることを確認

## 開発者向け情報

### 新しい機能の追加
1. **ネイティブ機能**: `proxy_detector.cpp`でWindows API機能を実装
2. **メソッドチャンネル**: `flutter_window.cpp`でハンドラーを追加
3. **リポジトリ**: `windows_proxy_repository.dart`でメソッドを追加
4. **サービス**: `proxy_service.dart`でビジネスロジックを追加
5. **UI**: `main.dart`で表示を更新

### プロジェクト構造
```
lib/
├── models/
│   └── proxy_settings.dart                 # データモデル
├── repositories/
│   ├── proxy_repository.dart               # リポジトリインターフェース
│   ├── windows_proxy_repository.dart       # Windows実装
│   ├── ios_proxy_repository.dart           # iOS実装
│   ├── android_proxy_repository.dart       # Android実装
│   └── platform_proxy_repository.dart      # プラットフォーム自動判定
├── services/
│   └── proxy_service.dart                  # ビジネスロジック
├── proxy_detector.dart                     # ライブラリエクスポート
└── main.dart                               # UIアプリケーション

example/
└── proxy_detector_example.dart             # 使用例

windows/runner/
├── proxy_detector.h/cpp                    # ネイティブ実装
└── flutter_window.cpp                      # メソッドチャンネル

ios/Runner/
├── ProxyDetector.swift                     # ネイティブ実装
└── AppDelegate.swift                       # メソッドチャンネル

android/app/src/main/kotlin/
├── ProxyDetector.kt                        # ネイティブ実装
└── MainActivity.kt                         # メソッドチャンネル

ANDROID_SETUP.md                            # Androidセットアップガイド
IOS_SETUP.md                                # iOSセットアップガイド
```

### デバッグ
- Visual Studioでネイティブコードをデバッグ可能
- Flutter DevToolsでUIをデバッグ可能