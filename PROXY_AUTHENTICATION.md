# プロキシ認証機能ガイド

## 概要

現在の実装では、**システムからプロキシ認証情報（ユーザー名・パスワード）を自動取得する機能は含まれていません**。

これはセキュリティとプライバシー保護のため、すべてのプラットフォーム（Windows、iOS、Android）で意図的な制限です。

## なぜ自動取得できないのか？

### セキュリティ上の理由

1. **プライバシー保護**
   - 認証情報は極めて機密性の高いデータ
   - 悪意のあるアプリによる不正取得を防ぐ

2. **プラットフォーム制限**
   - Windows: WinHTTP APIは認証情報を返さない
   - iOS: System Configurationは認証情報を含まない
   - Android: LinkPropertiesに認証情報は含まれない

3. **暗号化保存**
   - OSは認証情報を暗号化して保存
   - アプリからのアクセスは制限される

## 代替ソリューション

### 方法1: ユーザー入力による認証情報の管理（推奨）

ユーザーに認証情報を入力してもらい、安全に保存します。

#### 1. 必要なパッケージを追加

`pubspec.yaml`に追加:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_secure_storage: ^9.0.0  # 認証情報の安全な保存
```

インストール:
```bash
flutter pub get
```

#### 2. 認証情報の保存と取得

```dart
import 'package:proxy_detector/models/proxy_credentials.dart';
import 'package:proxy_detector/services/proxy_credentials_service.dart';

// サービスを初期化
final credentialsService = ProxyCredentialsService();

// ユーザーが入力した認証情報を保存
final credentials = ProxyCredentials(
  username: 'myuser',
  password: 'mypassword',
  authType: ProxyAuthType.basic,
);

await credentialsService.saveCredentials(credentials);

// 保存された認証情報を取得
final saved = await credentialsService.getCredentials();
print('ユーザー名: ${saved.username}');

// 認証情報が保存されているか確認
final hasAuth = await credentialsService.hasCredentials();
print('認証情報あり: $hasAuth');

// 認証情報を削除
await credentialsService.deleteCredentials();
```

#### 3. UI実装例

```dart
import 'package:flutter/material.dart';
import 'package:proxy_detector/models/proxy_credentials.dart';
import 'package:proxy_detector/services/proxy_credentials_service.dart';

class ProxyAuthSettingsPage extends StatefulWidget {
  const ProxyAuthSettingsPage({Key? key}) : super(key: key);

  @override
  State<ProxyAuthSettingsPage> createState() => _ProxyAuthSettingsPageState();
}

class _ProxyAuthSettingsPageState extends State<ProxyAuthSettingsPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _credentialsService = ProxyCredentialsService();
  ProxyAuthType _authType = ProxyAuthType.basic;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = await _credentialsService.getCredentials();
    setState(() {
      _usernameController.text = credentials.username;
      _passwordController.text = credentials.password;
      _authType = credentials.authType;
    });
  }

  Future<void> _saveCredentials() async {
    final credentials = ProxyCredentials(
      username: _usernameController.text,
      password: _passwordController.text,
      authType: _authType,
    );

    await _credentialsService.saveCredentials(credentials);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('認証情報を保存しました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('プロキシ認証設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'パスワード',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ProxyAuthType>(
              value: _authType,
              decoration: const InputDecoration(
                labelText: '認証方式',
                border: OutlineInputBorder(),
              ),
              items: ProxyAuthType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _authType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCredentials,
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

### 方法2: HTTP クライアントでの認証設定

プロキシ認証情報を使用してHTTPリクエストを送信する例：

```dart
import 'package:http/http.dart' as http;
import 'package:proxy_detector/proxy_detector.dart';

Future<void> makeAuthenticatedRequest() async {
  // プロキシ設定を取得
  final proxyService = ProxyService(PlatformProxyRepository.create());
  final proxySettings = await proxyService.getProxySettings();
  
  // 認証情報を取得
  final credentialsService = ProxyCredentialsService();
  final credentials = await credentialsService.getCredentials();

  if (proxySettings.isEnabled && credentials.hasCredentials) {
    // プロキシとBasic認証を使用したリクエスト
    final client = http.Client();
    
    try {
      final response = await client.get(
        Uri.parse('https://example.com'),
        headers: {
          'Proxy-Authorization': credentials.toBasicAuthHeader(),
        },
      );
      
      print('ステータス: ${response.statusCode}');
      print('レスポンス: ${response.body}');
    } finally {
      client.close();
    }
  }
}
```

### 方法3: 環境変数から取得（開発・テスト用）

開発環境では環境変数から認証情報を読み取ることも可能：

```dart
import 'dart:io';

class EnvironmentProxyCredentials {
  static ProxyCredentials fromEnvironment() {
    // HTTP_PROXY環境変数から取得
    // 形式: http://username:password@proxy:port
    final httpProxy = Platform.environment['HTTP_PROXY'] ?? 
                      Platform.environment['http_proxy'] ?? '';
    
    if (httpProxy.isEmpty) {
      return ProxyCredentials.empty();
    }
    
    final uri = Uri.tryParse(httpProxy);
    if (uri == null || uri.userInfo.isEmpty) {
      return ProxyCredentials.empty();
    }
    
    final parts = uri.userInfo.split(':');
    if (parts.length != 2) {
      return ProxyCredentials.empty();
    }
    
    return ProxyCredentials(
      username: parts[0],
      password: parts[1],
      authType: ProxyAuthType.basic,
    );
  }
}

// 使用例
void main() async {
  // 環境変数: HTTP_PROXY=http://user:pass@proxy:8080
  final envCredentials = EnvironmentProxyCredentials.fromEnvironment();
  print('ユーザー名: ${envCredentials.username}');
}
```

## セキュリティのベストプラクティス

### 1. 暗号化ストレージの使用

**必須**: `flutter_secure_storage`を使用して認証情報を暗号化して保存

```dart
// ✅ 良い例
final storage = FlutterSecureStorage();
await storage.write(key: 'proxy_password', value: password);

// ❌ 悪い例 - 平文で保存しない
final prefs = await SharedPreferences.getInstance();
await prefs.setString('proxy_password', password); // 危険！
```

### 2. メモリ上の認証情報の最小化

```dart
// ✅ 良い例 - 使用後すぐに破棄
Future<void> authenticate() async {
  final credentials = await credentialsService.getCredentials();
  await makeRequest(credentials);
  // credentialsは関数終了時に自動的にGCされる
}

// ❌ 悪い例 - 長時間メモリに保持
class MyApp extends StatefulWidget {
  final ProxyCredentials credentials; // グローバルに保持しない
}
```

### 3. ログに認証情報を出力しない

```dart
// ✅ 良い例
print('認証成功: ${credentials.username}'); // ユーザー名のみ

// ❌ 悪い例
print('パスワード: ${credentials.password}'); // パスワードを出力しない
print(credentials.toMap()); // パスワードが含まれる
```

### 4. HTTPSの使用

```dart
// ✅ 良い例 - HTTPSを使用
final url = 'https://api.example.com';

// ❌ 悪い例 - HTTPで認証情報を送信しない
final url = 'http://api.example.com'; // 危険！
```

## プラットフォーム固有の考慮事項

### Windows

Windowsの資格情報マネージャーと統合する場合:

```dart
// ネイティブコードでの実装が必要
// lib/repositories/windows_credentials_repository.dart

class WindowsCredentialsRepository {
  static const MethodChannel _channel = 
      MethodChannel('proxy_credentials');
  
  Future<ProxyCredentials> getFromCredentialManager() async {
    try {
      final Map<dynamic, dynamic> result = 
          await _channel.invokeMethod('getCredentials');
      
      return ProxyCredentials(
        username: result['username'] as String,
        password: result['password'] as String,
      );
    } catch (e) {
      return ProxyCredentials.empty();
    }
  }
}
```

### iOS

iOSのキーチェーンを使用（`flutter_secure_storage`が内部で使用）:

```dart
// iOSでは追加の設定は不要
// flutter_secure_storage が自動的にキーチェーンを使用
final service = ProxyCredentialsService();
await service.saveCredentials(credentials); // キーチェーンに保存
```

### Android

Androidの暗号化共有設定を使用（`flutter_secure_storage`が内部で使用）:

```dart
// Androidでは追加の設定は不要
// flutter_secure_storage が自動的に暗号化
final service = ProxyCredentialsService();
await service.saveCredentials(credentials); // 暗号化して保存
```

## 認証方式の対応状況

| 認証方式 | 対応状況 | 実装方法 |
|---------|---------|---------|
| **Basic認証** | ✅ 完全対応 | `credentials.toBasicAuthHeader()` |
| **Digest認証** | ⚠️ 要実装 | カスタム実装が必要 |
| **NTLM認証** | ⚠️ 要実装 | Windowsネイティブ実装が必要 |
| **Kerberos認証** | ⚠️ 要実装 | プラットフォーム固有実装が必要 |

## トラブルシューティング

### 認証情報が保存されない

**原因**: `flutter_secure_storage`のセットアップ不足

**解決方法**:

Android (`android/app/build.gradle.kts`):
```kotlin
android {
    defaultConfig {
        minSdk = 21 // 21以上であることを確認
    }
}
```

iOS: Xcode設定で「Keychain Sharing」を有効化

### 認証に失敗する

**確認事項**:
1. ユーザー名とパスワードが正しいか
2. 認証方式が正しいか（Basic/Digest/NTLM）
3. プロキシサーバーが認証を要求しているか
4. HTTPSを使用しているか

## まとめ

プロキシ認証機能の実装状況：

- ❌ **システムから自動取得**: すべてのプラットフォームで不可能（セキュリティ上の制限）
- ✅ **ユーザー入力による管理**: 完全対応（推奨方法）
- ✅ **安全な保存**: `flutter_secure_storage`で暗号化
- ✅ **Basic認証**: 完全対応
- ⚠️ **その他の認証方式**: カスタム実装が必要

### 推奨される実装フロー

1. プロキシ設定を自動検出（`ProxyService`）
2. ユーザーに認証情報を入力してもらう（UI）
3. 認証情報を安全に保存（`ProxyCredentialsService`）
4. HTTPリクエスト時に認証ヘッダーを追加

これにより、セキュリティを保ちながら、プロキシ認証機能を提供できます。

