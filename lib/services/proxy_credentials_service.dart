import 'dart:convert';
import '../models/proxy_credentials.dart';

/// プロキシ認証情報を安全に保存・取得するサービス（インターフェース）
/// 
/// 注意: このサービスを使用するには、flutter_secure_storage パッケージを
/// pubspec.yaml に追加する必要があります:
/// 
/// dependencies:
///   flutter_secure_storage: ^9.0.0
/// 
/// 使用方法:
/// ```dart
/// // flutter_secure_storage をインストール後
/// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
/// 
/// final storage = FlutterSecureStorage();
/// final service = ProxyCredentialsService(storage);
/// 
/// // 認証情報を保存
/// await service.saveCredentials(ProxyCredentials(
///   username: 'user',
///   password: 'pass',
/// ));
/// 
/// // 認証情報を取得
/// final credentials = await service.getCredentials();
/// ```
class ProxyCredentialsService {
  static const String _storageKey = 'proxy_credentials';
  final SecureStorage _storage;

  /// コンストラクタ
  ProxyCredentialsService(this._storage);

  /// 認証情報を保存
  /// 
  /// 認証情報は暗号化されてデバイスに安全に保存されます。
  Future<void> saveCredentials(ProxyCredentials credentials) async {
    try {
      final json = jsonEncode(credentials.toMap());
      await _storage.write(key: _storageKey, value: json);
    } catch (e) {
      throw ProxyCredentialsException(
        '認証情報の保存に失敗しました',
        e,
      );
    }
  }

  /// 認証情報を取得
  /// 
  /// Returns: 保存されている認証情報、または空の認証情報
  Future<ProxyCredentials> getCredentials() async {
    try {
      final json = await _storage.read(key: _storageKey);
      
      if (json == null || json.isEmpty) {
        return ProxyCredentials.empty();
      }
      
      final map = jsonDecode(json) as Map<String, dynamic>;
      return ProxyCredentials.fromMap(map);
    } catch (e) {
      throw ProxyCredentialsException(
        '認証情報の取得に失敗しました',
        e,
      );
    }
  }

  /// 認証情報を削除
  Future<void> deleteCredentials() async {
    try {
      await _storage.delete(key: _storageKey);
    } catch (e) {
      throw ProxyCredentialsException(
        '認証情報の削除に失敗しました',
        e,
      );
    }
  }

  /// 認証情報が保存されているか確認
  Future<bool> hasCredentials() async {
    try {
      final json = await _storage.read(key: _storageKey);
      return json != null && json.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// すべてのストレージをクリア
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw ProxyCredentialsException(
        'ストレージのクリアに失敗しました',
        e,
      );
    }
  }
}

/// プロキシ認証情報サービスで発生する例外
class ProxyCredentialsException implements Exception {
  final String message;
  final dynamic originalError;

  ProxyCredentialsException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'ProxyCredentialsException: $message (原因: $originalError)';
    }
    return 'ProxyCredentialsException: $message';
  }
}

/// セキュアストレージのインターフェース
/// 
/// flutter_secure_storage パッケージをインストールして使用してください。
abstract class SecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

