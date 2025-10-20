# プロキシ認証入力画面 使用ガイド

## 概要

プロキシ認証情報（ユーザー名・パスワード）を入力・管理するための画面を追加しました。

## 画面の表示方法

### 1. アプリバーのボタンから開く

メイン画面のアプリバー（上部）に **鍵アイコン** （🔑）のボタンがあります。

```
┌─────────────────────────────────────┐
│ Windows プロキシ設定検出   🔑 🔄   │ ← ここをタップ
├─────────────────────────────────────┤
│                                     │
│         プロキシ設定内容            │
│                                     │
└─────────────────────────────────────┘
```

**操作手順**:
1. アプリを起動
2. 右上の **鍵アイコン** をタップ
3. プロキシ認証設定画面が表示されます

### 2. コードから直接開く

プログラムから直接開くこともできます：

```dart
import 'package:flutter/material.dart';
import 'pages/proxy_auth_settings_page.dart';
import 'services/proxy_credentials_service.dart';

// 画面を表示
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => ProxyAuthSettingsPage(
      storage: yourSecureStorage,
    ),
  ),
);
```

## 認証設定画面の使い方

### 画面レイアウト

```
┌─────────────────────────────────────┐
│ プロキシ認証設定          🗑️      │
├─────────────────────────────────────┤
│                                     │
│ ℹ️  プロキシ認証が必要な場合は、    │
│    ユーザー名とパスワードを入力    │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 👤 ユーザー名                   │ │
│ │ [___________________________]   │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🔒 パスワード              👁️  │ │
│ │ [•••••••••••••••••••••••••]    │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ 🛡️ 認証方式                     │ │
│ │ [Basic認証 ▼]                  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │     💾 保存                     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ⚠️  セキュリティに関する注意       │
│    認証情報は暗号化されて保存      │
│                                     │
└─────────────────────────────────────┘
```

### 入力項目

#### 1. ユーザー名
- プロキシサーバーのユーザー名を入力
- 必須項目

#### 2. パスワード
- プロキシサーバーのパスワードを入力
- 必須項目
- 👁️ アイコンで表示/非表示を切り替え可能

#### 3. 認証方式
- **Basic認証** (推奨・デフォルト)
- Digest認証
- NTLM認証
- Kerberos認証

※現在、完全に対応しているのはBasic認証のみです

### 操作方法

#### 新規登録する場合

1. ユーザー名を入力
2. パスワードを入力
3. 認証方式を選択（通常はBasic認証）
4. **保存** ボタンをタップ
5. 「認証情報を保存しました」というメッセージが表示されます

#### 既存の認証情報を編集する場合

1. 画面を開くと、保存されている情報が自動的に表示されます
2. 必要な項目を変更
3. **保存** ボタンをタップ

#### 認証情報を削除する場合

1. 右上の **ゴミ箱アイコン** (🗑️) をタップ
2. 確認ダイアログが表示されます
3. **削除** をタップすると削除されます

## 実装の詳細

### ファイル構成

```
lib/
├── pages/
│   └── proxy_auth_settings_page.dart  # 認証設定画面
├── models/
│   └── proxy_credentials.dart         # 認証情報モデル
├── services/
│   └── proxy_credentials_service.dart # 認証情報サービス
└── main.dart                          # メイン画面（ボタン追加済み）
```

### セキュリティ機能

#### 1. パスワードの非表示

デフォルトでパスワードは `•••••` で表示されます：

```dart
TextFormField(
  obscureText: true,  // パスワードを隠す
  decoration: InputDecoration(
    suffixIcon: IconButton(
      icon: Icon(Icons.visibility), // 表示/非表示切り替え
      onPressed: () { /* 切り替え処理 */ },
    ),
  ),
)
```

#### 2. 暗号化保存

認証情報はメモリ上の辞書に保存されます（デモ版）：

```dart
// デモ版（開発・テスト用）
class _DemoSecureStorage implements SecureStorage {
  static final Map<String, String> _storage = {};
  // ...
}
```

**本番環境では `flutter_secure_storage` を使用してください**：

```yaml
# pubspec.yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 本番環境での使用
final storage = FlutterSecureStorage();
final credentialsService = ProxyCredentialsService(storage);
```

#### 3. バリデーション

入力内容の検証：

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'ユーザー名を入力してください';
  }
  return null;
}
```

### カスタマイズ方法

#### 1. UIのカスタマイズ

色やレイアウトを変更：

```dart
// lib/pages/proxy_auth_settings_page.dart

// 保存ボタンの色を変更
ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,  // 背景色
    foregroundColor: Colors.white,  // 文字色
    padding: const EdgeInsets.all(16),
  ),
  // ...
)
```

#### 2. デフォルト認証方式の変更

```dart
class _ProxyAuthSettingsPageState extends State<ProxyAuthSettingsPage> {
  ProxyAuthType _authType = ProxyAuthType.ntlm;  // NTLMをデフォルトに
  // ...
}
```

#### 3. 追加のバリデーション

```dart
validator: (value) {
  if (value == null || value.isEmpty) {
    return 'パスワードを入力してください';
  }
  if (value.length < 8) {
    return 'パスワードは8文字以上にしてください';
  }
  return null;
}
```

## 実際の使用例

### シナリオ1: 企業プロキシの設定

```
会社のプロキシサーバーを使用する場合

ユーザー名: employee123
パスワード: SecurePassword!
認証方式: NTLM認証
```

### シナリオ2: テスト環境のプロキシ

```
開発用のローカルプロキシを使用する場合

ユーザー名: testuser
パスワード: testpass
認証方式: Basic認証
```

### シナリオ3: 認証情報の変更

```
パスワードが変更された場合

1. 🔑 ボタンをタップ
2. 新しいパスワードを入力
3. 保存ボタンをタップ
4. 「認証情報を保存しました」と表示される
```

## トラブルシューティング

### Q1: 保存ボタンを押しても反応しない

**原因**: 入力エラーがある

**解決方法**:
- ユーザー名とパスワードの両方を入力してください
- エラーメッセージが表示されていないか確認してください

### Q2: 画面が開かない

**原因**: ナビゲーションエラー

**確認事項**:
```dart
// lib/main.dart で正しくインポートされているか確認
import 'pages/proxy_auth_settings_page.dart';
import 'services/proxy_credentials_service.dart';
```

### Q3: 認証情報が保存されない

**原因**: セキュアストレージの初期化エラー

**解決方法**:
```dart
// デバッグ出力を追加
Future<void> _saveCredentials() async {
  try {
    print('認証情報を保存中...');
    await _credentialsService.saveCredentials(credentials);
    print('保存成功！');
  } catch (e) {
    print('保存エラー: $e');
  }
}
```

### Q4: 画面遷移後に情報が消える

**原因**: デモ版のストレージは一時的

**解決方法**:
本番環境では `flutter_secure_storage` を使用してください：

```bash
flutter pub add flutter_secure_storage
```

```dart
// main.dart
SecureStorage _createSecureStorage() {
  return FlutterSecureStorage(); // デモ版から変更
}
```

## まとめ

### 表示方法
✅ アプリバーの **🔑 ボタン** をタップ

### 機能
✅ ユーザー名・パスワードの入力  
✅ 認証方式の選択  
✅ パスワードの表示/非表示切り替え  
✅ 認証情報の保存・編集・削除  
✅ バリデーション機能  
✅ セキュアな保存（本番環境）

### 次のステップ
1. アプリを起動
2. 🔑 ボタンをタップして認証設定画面を開く
3. プロキシの認証情報を入力
4. 保存ボタンをタップ

これで、プロキシ認証が必要な環境でもアプリを使用できます！

