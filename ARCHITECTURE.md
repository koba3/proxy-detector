# アーキテクチャドキュメント

## 概要

このプロジェクトは、**クリーンアーキテクチャ**と**依存性注入パターン**を採用した、疎結合で再利用可能な設計になっています。

## 設計原則

### 1. 関心の分離（Separation of Concerns）
各レイヤーは明確な責任を持ち、他のレイヤーに依存しません。

### 2. 依存性の逆転（Dependency Inversion）
上位レイヤーは抽象（インターフェース）に依存し、具体的な実装には依存しません。

### 3. 単一責任の原則（Single Responsibility）
各クラスは1つの責任のみを持ちます。

### 4. オープン・クローズドの原則（Open/Closed）
拡張に対して開いており、修正に対して閉じています。

## レイヤー構造

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│                      (UI / main.dart)                   │
│  - ユーザーインターフェース                             │
│  - ユーザー入力の処理                                   │
│  - データの表示                                         │
└─────────────────────────────────────────────────────────┘
                            ↓ 依存
┌─────────────────────────────────────────────────────────┐
│                     Service Layer                       │
│                  (services/proxy_service.dart)          │
│  - ビジネスロジック                                     │
│  - データの変換・検証                                   │
│  - エラーハンドリング                                   │
└─────────────────────────────────────────────────────────┘
                            ↓ 依存（抽象）
┌─────────────────────────────────────────────────────────┐
│                   Repository Layer                      │
│         (repositories/proxy_repository.dart)            │
│  - データソースの抽象化                                 │
│  - プラットフォーム非依存のインターフェース             │
└─────────────────────────────────────────────────────────┘
                            ↑ 実装
┌─────────────────────────────────────────────────────────┐
│                  Infrastructure Layer                   │
│      (repositories/windows_proxy_repository.dart)       │
│  - プラットフォーム固有の実装                           │
│  - ネイティブAPIとの通信                                │
│  - 外部システムとの統合                                 │
└─────────────────────────────────────────────────────────┘
                            ↓ 使用
┌─────────────────────────────────────────────────────────┐
│                      Domain Layer                       │
│                (models/proxy_settings.dart)             │
│  - ドメインモデル                                       │
│  - ビジネスエンティティ                                 │
│  - プラットフォーム完全非依存                           │
└─────────────────────────────────────────────────────────┘
```

## 各レイヤーの詳細

### 1. Domain Layer（ドメイン層）

**場所**: `lib/models/`

**責任**:
- ビジネスドメインのエンティティを定義
- プラットフォームやフレームワークに依存しない純粋なDartコード
- 不変オブジェクトとして設計

**ファイル**:
- `proxy_settings.dart`: プロキシ設定のデータモデル

**特徴**:
- 外部依存なし
- イミュータブル（const コンストラクタ）
- シリアライズ/デシリアライズ対応
- 等価性比較とハッシュコード実装

**例**:
```dart
const settings = ProxySettings(
  isEnabled: true,
  proxyServer: 'proxy.example.com:8080',
  bypassList: 'localhost',
  autoDetect: false,
  autoConfigUrl: '',
);
```

### 2. Repository Layer（リポジトリ層）

**場所**: `lib/repositories/`

**責任**:
- データソースへのアクセスを抽象化
- プラットフォーム非依存のインターフェースを提供
- データの取得・保存ロジックをカプセル化

**ファイル**:
- `proxy_repository.dart`: 抽象インターフェース
- `windows_proxy_repository.dart`: Windows実装

**特徴**:
- インターフェースと実装の分離
- 依存性注入により実装を切り替え可能
- エラーハンドリングの統一

**インターフェース設計**:
```dart
abstract class ProxyRepository {
  Future<ProxySettings> getProxySettings();
  Future<bool> isProxyEnabled();
  Future<String> getProxyServer();
}
```

**実装例**:
```dart
class WindowsProxyRepository implements ProxyRepository {
  final MethodChannel _channel;
  
  WindowsProxyRepository({String channelName = 'proxy_detector'})
      : _channel = MethodChannel(channelName);
  
  @override
  Future<ProxySettings> getProxySettings() async {
    // Windows固有の実装
  }
}
```

### 3. Service Layer（サービス層）

**場所**: `lib/services/`

**責任**:
- ビジネスロジックの実装
- リポジトリを通じてデータを取得・操作
- データの変換・検証
- 複数のリポジトリの調整

**ファイル**:
- `proxy_service.dart`: プロキシサービス

**特徴**:
- リポジトリへの依存は抽象インターフェース経由
- ビジネスルールの実装
- エラーハンドリングとロギング

**使用例**:
```dart
class ProxyService {
  final ProxyRepository _repository;
  
  ProxyService(this._repository);
  
  Future<ProxySettings> getProxySettings() async {
    try {
      return await _repository.getProxySettings();
    } catch (e) {
      throw ProxyServiceException('取得失敗', e);
    }
  }
  
  Future<bool> isProxyFullyConfigured() async {
    final settings = await getProxySettings();
    return settings.isEnabled && settings.proxyServer.isNotEmpty;
  }
}
```

### 4. Presentation Layer（プレゼンテーション層）

**場所**: `lib/main.dart`

**責任**:
- ユーザーインターフェースの実装
- ユーザー入力の処理
- データの表示
- サービス層との連携

**特徴**:
- Flutterウィジェットの実装
- 状態管理
- サービスへの依存は依存性注入経由

**使用例**:
```dart
class _ProxyDetectorPageState extends State<ProxyDetectorPage> {
  late final ProxyService _proxyService;
  
  @override
  void initState() {
    super.initState();
    // 依存性注入
    _proxyService = ProxyService(WindowsProxyRepository());
    _loadProxySettings();
  }
  
  Future<void> _loadProxySettings() async {
    final settings = await _proxyService.getProxySettings();
    // UIを更新
  }
}
```

## データフロー

### 読み取りフロー（プロキシ設定の取得）

```
1. UI (main.dart)
   ↓ _proxyService.getProxySettings()
2. Service (proxy_service.dart)
   ↓ _repository.getProxySettings()
3. Repository (windows_proxy_repository.dart)
   ↓ _channel.invokeMethod('getProxySettings')
4. Native Code (flutter_window.cpp)
   ↓ ProxyDetector::GetSystemProxySettings()
5. Windows API (proxy_detector.cpp)
   ↓ WinHttpGetIEProxyConfigForCurrentUser()
6. Windows System
   ← 返り値
7. Native Code
   ← Map<dynamic, dynamic>
8. Repository
   ← ProxySettings.fromMap()
9. Service
   ← ProxySettings
10. UI
```

## 依存性注入パターン

### コンストラクタインジェクション

```dart
// サービスはリポジトリインターフェースに依存
class ProxyService {
  final ProxyRepository _repository;
  
  ProxyService(this._repository);  // コンストラクタで注入
}

// 使用時に具体的な実装を注入
final service = ProxyService(WindowsProxyRepository());
```

### 利点

1. **テスタビリティ**: モックリポジトリを注入してテスト可能
2. **柔軟性**: 実装を簡単に切り替え可能
3. **疎結合**: 上位レイヤーは具体的な実装を知らない

## 拡張性

### 新しいプラットフォームの追加

例: macOS対応

```dart
// 1. macOS用リポジトリを実装
class MacOSProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    // macOS固有の実装
  }
  
  @override
  Future<bool> isProxyEnabled() async { ... }
  
  @override
  Future<String> getProxyServer() async { ... }
}

// 2. プラットフォームに応じて切り替え
ProxyRepository createRepository() {
  if (Platform.isWindows) {
    return WindowsProxyRepository();
  } else if (Platform.isMacOS) {
    return MacOSProxyRepository();
  }
  throw UnsupportedError('Unsupported platform');
}

// 3. 使用
final service = ProxyService(createRepository());
```

### 新しいデータソースの追加

例: リモートAPIからプロキシ設定を取得

```dart
class RemoteProxyRepository implements ProxyRepository {
  final http.Client _client;
  final String _apiUrl;
  
  RemoteProxyRepository(this._client, this._apiUrl);
  
  @override
  Future<ProxySettings> getProxySettings() async {
    final response = await _client.get(Uri.parse('$_apiUrl/proxy'));
    return ProxySettings.fromMap(jsonDecode(response.body));
  }
  
  // ... 他のメソッド
}

// 使用
final service = ProxyService(
  RemoteProxyRepository(http.Client(), 'https://api.example.com')
);
```

### キャッシュ機能の追加

```dart
class CachedProxyRepository implements ProxyRepository {
  final ProxyRepository _innerRepository;
  ProxySettings? _cachedSettings;
  DateTime? _cacheTime;
  final Duration _cacheDuration;
  
  CachedProxyRepository(
    this._innerRepository,
    {Duration cacheDuration = const Duration(minutes: 5)}
  ) : _cacheDuration = cacheDuration;
  
  @override
  Future<ProxySettings> getProxySettings() async {
    if (_cachedSettings != null && 
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cachedSettings!;
    }
    
    _cachedSettings = await _innerRepository.getProxySettings();
    _cacheTime = DateTime.now();
    return _cachedSettings!;
  }
  
  // ... 他のメソッド
}

// 使用（デコレーターパターン）
final service = ProxyService(
  CachedProxyRepository(WindowsProxyRepository())
);
```

## テスト戦略

### ユニットテスト

```dart
// モックリポジトリを使用してサービスをテスト
test('プロキシ設定が完全に設定されている場合はtrueを返す', () async {
  final mockRepo = MockProxyRepository();
  when(mockRepo.getProxySettings()).thenAnswer((_) async =>
    ProxySettings(
      isEnabled: true,
      proxyServer: 'proxy:8080',
      bypassList: '',
      autoDetect: false,
      autoConfigUrl: '',
    )
  );
  
  final service = ProxyService(mockRepo);
  final result = await service.isProxyFullyConfigured();
  
  expect(result, true);
});
```

### 統合テスト

```dart
// 実際のリポジトリを使用してテスト
testWidgets('プロキシ設定が正しく表示される', (tester) async {
  final service = ProxyService(WindowsProxyRepository());
  
  await tester.pumpWidget(
    MaterialApp(
      home: ProxyDetectorPage(proxyService: service),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.text('プロキシ設定状態'), findsOneWidget);
});
```

## ベストプラクティス

### 1. イミュータブルなデータモデル
```dart
// Good: constコンストラクタとfinalフィールド
class ProxySettings {
  final bool isEnabled;
  final String proxyServer;
  
  const ProxySettings({
    required this.isEnabled,
    required this.proxyServer,
  });
}
```

### 2. 明示的なエラーハンドリング
```dart
// Good: カスタム例外クラス
class ProxyRepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  
  ProxyRepositoryException(this.message, [this.originalError]);
}
```

### 3. 依存性の注入
```dart
// Good: コンストラクタで依存性を受け取る
class ProxyService {
  final ProxyRepository _repository;
  ProxyService(this._repository);
}

// Bad: 内部でインスタンスを作成
class ProxyService {
  final _repository = WindowsProxyRepository(); // 疎結合ではない
}
```

### 4. インターフェースへの依存
```dart
// Good: 抽象クラスに依存
class ProxyService {
  final ProxyRepository _repository;  // インターフェース
}

// Bad: 具体的な実装に依存
class ProxyService {
  final WindowsProxyRepository _repository;  // 具体的な実装
}
```

## まとめ

このアーキテクチャの利点：

1. **再利用性**: 各コンポーネントが独立しており、他のプロジェクトで再利用可能
2. **テスタビリティ**: モックを使用して各レイヤーを独立してテスト可能
3. **保守性**: 関心の分離により、変更の影響範囲が限定的
4. **拡張性**: 新しいプラットフォームやデータソースを簡単に追加可能
5. **可読性**: 明確なレイヤー構造により、コードの理解が容易

このアーキテクチャにより、プロキシ検出ロジックは完全に疎結合となり、
どのFlutterプロジェクトでも簡単に統合できます。

