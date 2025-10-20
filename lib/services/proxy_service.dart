import '../models/proxy_settings.dart';
import '../repositories/proxy_repository.dart';

/// プロキシ設定を管理するサービスクラス
/// 
/// このクラスはビジネスロジック層として機能し、
/// リポジトリを通じてプロキシ設定を取得・管理します。
/// 依存性注入により、異なるリポジトリ実装を使用できます。
class ProxyService {
  final ProxyRepository _repository;

  /// コンストラクタ
  /// 
  /// [repository] プロキシ設定を取得するリポジトリ実装
  ProxyService(this._repository);

  /// システムのプロキシ設定を取得
  /// 
  /// Returns: [ProxySettings] プロキシ設定オブジェクト
  /// Throws: [ProxyServiceException] 取得に失敗した場合
  Future<ProxySettings> getProxySettings() async {
    try {
      return await _repository.getProxySettings();
    } catch (e) {
      throw ProxyServiceException(
        'プロキシ設定の取得に失敗しました',
        e,
      );
    }
  }

  /// プロキシが有効かどうかを確認
  /// 
  /// Returns: プロキシが有効な場合は true、無効な場合は false
  /// Throws: [ProxyServiceException] 確認に失敗した場合
  Future<bool> isProxyEnabled() async {
    try {
      return await _repository.isProxyEnabled();
    } catch (e) {
      throw ProxyServiceException(
        'プロキシ状態の確認に失敗しました',
        e,
      );
    }
  }

  /// プロキシサーバーのアドレスを取得
  /// 
  /// Returns: プロキシサーバーのアドレス（設定されていない場合は空文字列）
  /// Throws: [ProxyServiceException] 取得に失敗した場合
  Future<String> getProxyServer() async {
    try {
      return await _repository.getProxyServer();
    } catch (e) {
      throw ProxyServiceException(
        'プロキシサーバー情報の取得に失敗しました',
        e,
      );
    }
  }

  /// プロキシ設定が完全に設定されているかを確認
  /// 
  /// Returns: プロキシが有効でサーバーが設定されている場合は true
  Future<bool> isProxyFullyConfigured() async {
    try {
      final settings = await getProxySettings();
      return settings.isEnabled && settings.proxyServer.isNotEmpty;
    } catch (e) {
      throw ProxyServiceException(
        'プロキシ設定の確認に失敗しました',
        e,
      );
    }
  }

  /// プロキシ設定のサマリーを文字列で取得
  /// 
  /// Returns: プロキシ設定の概要を示す文字列
  Future<String> getProxySettingsSummary() async {
    try {
      final settings = await getProxySettings();
      
      if (!settings.isEnabled) {
        return 'プロキシは無効です';
      }

      final parts = <String>[];
      
      if (settings.proxyServer.isNotEmpty) {
        parts.add('サーバー: ${settings.proxyServer}');
      }
      
      if (settings.autoDetect) {
        parts.add('自動検出: 有効');
      }
      
      if (settings.autoConfigUrl.isNotEmpty) {
        parts.add('自動設定URL: ${settings.autoConfigUrl}');
      }

      return parts.isEmpty ? 'プロキシは有効ですが、設定が見つかりません' : parts.join(', ');
    } catch (e) {
      throw ProxyServiceException(
        'プロキシ設定サマリーの取得に失敗しました',
        e,
      );
    }
  }
}

/// プロキシサービスで発生する例外
class ProxyServiceException implements Exception {
  final String message;
  final dynamic originalError;

  ProxyServiceException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'ProxyServiceException: $message (原因: $originalError)';
    }
    return 'ProxyServiceException: $message';
  }
}

