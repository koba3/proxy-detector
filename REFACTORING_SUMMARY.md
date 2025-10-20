# リファクタリング概要

## 実施内容

プロキシ検出ロジックを**疎結合で再利用可能な設計**にリファクタリングしました。

## 変更前の構造

```
lib/
├── main.dart           # UIとロジックが混在
└── proxy_service.dart  # 静的メソッドでネイティブコードと直接通信
```

**問題点**:
- ロジックとUIが密結合
- 静的メソッドによりテストが困難
- プラットフォーム依存のコードが分離されていない
- 他のプロジェクトでの再利用が困難

## 変更後の構造

```
lib/
├── models/
│   └── proxy_settings.dart           # データモデル（プラットフォーム非依存）
├── repositories/
│   ├── proxy_repository.dart         # リポジトリインターフェース
│   └── windows_proxy_repository.dart # Windows実装
├── services/
│   └── proxy_service.dart            # ビジネスロジック層
├── proxy_detector.dart               # ライブラリエクスポート
└── main.dart                         # UIのみ

example/
└── proxy_detector_example.dart       # 使用例

ARCHITECTURE.md                       # アーキテクチャドキュメント
```

## 新しいアーキテクチャの特徴

### 1. レイヤー分離

```
UI Layer (main.dart)
    ↓
Service Layer (proxy_service.dart)
    ↓
Repository Interface (proxy_repository.dart)
    ↑
Repository Implementation (windows_proxy_repository.dart)
    ↓
Domain Model (proxy_settings.dart)
```

### 2. 依存性注入パターン

**変更前**:
```dart
// 静的メソッド - テストが困難
final settings = await ProxyService.getProxySettings();
```

**変更後**:
```dart
// 依存性注入 - テスト可能
final repository = WindowsProxyRepository();
final service = ProxyService(repository);
final settings = await service.getProxySettings();
```

### 3. プラットフォーム抽象化

**変更前**:
```dart
class ProxyService {
  static const MethodChannel _channel = MethodChannel('proxy_detector');
  // Windows専用の実装が直接記述されている
}
```

**変更後**:
```dart
// インターフェース（プラットフォーム非依存）
abstract class ProxyRepository {
  Future<ProxySettings> getProxySettings();
}

// Windows実装（プラットフォーム固有）
class WindowsProxyRepository implements ProxyRepository {
  final MethodChannel _channel;
  // Windows固有の実装
}

// 将来的にmacOS、Linux等も追加可能
class MacOSProxyRepository implements ProxyRepository { ... }
```

## 主な変更点

### 1. データモデルの作成

**ファイル**: `lib/models/proxy_settings.dart`

- プロキシ設定を表すイミュータブルなデータクラス
- プラットフォーム非依存
- シリアライズ/デシリアライズ対応
- `copyWith`, `toMap`, `fromMap` メソッド実装

**利点**:
- 型安全性の向上
- データの不変性保証
- 他のプロジェクトでも再利用可能

### 2. リポジトリパターンの導入

**ファイル**: 
- `lib/repositories/proxy_repository.dart` (インターフェース)
- `lib/repositories/windows_proxy_repository.dart` (実装)

**利点**:
- データソースの抽象化
- 実装の切り替えが容易（Windows → macOS等）
- モックを使用したテストが可能

### 3. サービス層の作成

**ファイル**: `lib/services/proxy_service.dart`

- ビジネスロジックの実装
- リポジトリを通じてデータを取得
- 追加機能の提供:
  - `isProxyFullyConfigured()` - プロキシが完全に設定されているか確認
  - `getProxySettingsSummary()` - プロキシ設定のサマリーを取得

**利点**:
- ビジネスロジックの集約
- UIからロジックを分離
- 再利用可能なメソッド

### 4. UIの簡素化

**ファイル**: `lib/main.dart`

**変更前**:
```dart
final Map<String, dynamic> settings = await ProxyService.getProxySettings();
final isEnabled = settings['isEnabled'] as bool? ?? false;
```

**変更後**:
```dart
final ProxySettings settings = await _proxyService.getProxySettings();
final isEnabled = settings.isEnabled;
```

**利点**:
- 型安全性の向上
- コードの可読性向上
- nullチェックの簡素化

## 使用例

### 基本的な使用

```dart
import 'package:proxy_detector/proxy_detector.dart';

// リポジトリを選択
final repository = WindowsProxyRepository();

// サービスを初期化
final proxyService = ProxyService(repository);

// プロキシ設定を取得
final settings = await proxyService.getProxySettings();
print('プロキシ有効: ${settings.isEnabled}');
print('サーバー: ${settings.proxyServer}');
```

### テスト用モックの使用

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
final settings = await mockService.getProxySettings();
```

### カスタムリポジトリの実装

```dart
// 独自のプロキシ検出ロジック
class CustomProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    // カスタムロジックを実装
    // 例: 環境変数から取得、設定ファイルから読み込み等
  }
}

final service = ProxyService(CustomProxyRepository());
```

## 他のプロジェクトでの使用方法

### 方法1: ファイルをコピー

必要なファイルをコピー:
```
lib/models/proxy_settings.dart
lib/repositories/proxy_repository.dart
lib/repositories/windows_proxy_repository.dart
lib/services/proxy_service.dart
```

### 方法2: ライブラリとしてインポート

```dart
import 'package:proxy_detector/proxy_detector.dart';

void main() {
  final proxyService = ProxyService(WindowsProxyRepository());
  // 使用
}
```

### 方法3: パッケージとして公開

`pubspec.yaml` を設定してpub.devに公開することも可能です。

## テスト戦略

### ユニットテスト

```dart
test('プロキシが有効でサーバーが設定されている場合、完全に設定済みと判定', () async {
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
testWidgets('プロキシ設定が正しく表示される', (tester) async {
  final service = ProxyService(WindowsProxyRepository());
  
  await tester.pumpWidget(
    MaterialApp(home: ProxyDetectorPage(proxyService: service)),
  );
  
  await tester.pumpAndSettle();
  expect(find.text('プロキシ設定状態'), findsOneWidget);
});
```

## 拡張性

### 新しいプラットフォームの追加

```dart
// macOS対応を追加
class MacOSProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    // macOS固有の実装
  }
}

// プラットフォームに応じて切り替え
ProxyRepository createRepository() {
  if (Platform.isWindows) return WindowsProxyRepository();
  if (Platform.isMacOS) return MacOSProxyRepository();
  throw UnsupportedError('Unsupported platform');
}
```

### キャッシュ機能の追加

```dart
class CachedProxyRepository implements ProxyRepository {
  final ProxyRepository _innerRepository;
  ProxySettings? _cache;
  
  CachedProxyRepository(this._innerRepository);
  
  @override
  Future<ProxySettings> getProxySettings() async {
    if (_cache != null) return _cache!;
    _cache = await _innerRepository.getProxySettings();
    return _cache!;
  }
}

// デコレーターパターンで使用
final service = ProxyService(
  CachedProxyRepository(WindowsProxyRepository())
);
```

## 利点のまとめ

### 1. 再利用性
- 各コンポーネントが独立
- 他のプロジェクトで簡単に再利用可能
- プラットフォーム非依存のコードが明確

### 2. テスタビリティ
- モックを使用したユニットテストが容易
- 各レイヤーを独立してテスト可能
- 依存性注入により柔軟なテスト

### 3. 保守性
- 関心の分離により変更の影響範囲が限定的
- 明確なレイヤー構造で理解しやすい
- 各クラスの責任が明確

### 4. 拡張性
- 新しいプラットフォームを簡単に追加
- 新しいデータソースに対応可能
- デコレーターパターンで機能追加が容易

### 5. 型安全性
- Map<String, dynamic>からProxySettingsへ
- コンパイル時の型チェック
- IDEの補完機能が効く

## 参考ドキュメント

- `ARCHITECTURE.md` - 詳細なアーキテクチャ説明
- `example/proxy_detector_example.dart` - 実装例
- `README.md` - プロジェクト概要と使用方法

## 今後の改善案

1. **状態管理の導入**: Riverpod/Blocなどを使用してより洗練された状態管理
2. **エラーハンドリングの強化**: より詳細なエラー情報と回復処理
3. **ロギング機能**: デバッグ用のロギング機能追加
4. **設定の永続化**: SharedPreferencesを使用したキャッシュ
5. **パッケージ化**: pub.devへの公開

## まとめ

このリファクタリングにより、プロキシ検出ロジックは：
- ✅ 疎結合で再利用可能
- ✅ テスト可能
- ✅ 拡張可能
- ✅ 保守しやすい
- ✅ 型安全

他のプロジェクトでも簡単に統合できる、高品質なコンポーネントになりました。

