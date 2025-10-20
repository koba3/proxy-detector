import '../models/proxy_settings.dart';

/// プロキシ設定を取得するためのリポジトリインターフェース
/// 
/// このインターフェースを実装することで、異なるプラットフォームや
/// データソース（ネイティブAPI、モックデータ、リモートAPI等）に対応できます。
abstract class ProxyRepository {
  /// システムのプロキシ設定を取得
  /// 
  /// Returns: [ProxySettings] プロキシ設定オブジェクト
  /// Throws: [ProxyRepositoryException] 取得に失敗した場合
  Future<ProxySettings> getProxySettings();

  /// プロキシが有効かどうかを確認
  /// 
  /// Returns: プロキシが有効な場合は true、無効な場合は false
  /// Throws: [ProxyRepositoryException] 確認に失敗した場合
  Future<bool> isProxyEnabled();

  /// プロキシサーバーのアドレスを取得
  /// 
  /// Returns: プロキシサーバーのアドレス（設定されていない場合は空文字列）
  /// Throws: [ProxyRepositoryException] 取得に失敗した場合
  Future<String> getProxyServer();
}

/// プロキシリポジトリで発生する例外
class ProxyRepositoryException implements Exception {
  final String message;
  final dynamic originalError;

  ProxyRepositoryException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'ProxyRepositoryException: $message (原因: $originalError)';
    }
    return 'ProxyRepositoryException: $message';
  }
}

