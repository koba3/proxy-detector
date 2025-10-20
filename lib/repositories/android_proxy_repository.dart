import 'package:flutter/services.dart';
import '../models/proxy_settings.dart';
import 'proxy_repository.dart';

/// Android プラットフォーム向けのプロキシリポジトリ実装
/// 
/// ネイティブのAndroid System APIを使用してプロキシ設定を取得します。
/// Android 5.0 (API 21) 以降をサポートします。
class AndroidProxyRepository implements ProxyRepository {
  final MethodChannel _channel;

  /// コンストラクタ
  /// 
  /// [channelName] メソッドチャンネル名（デフォルト: 'proxy_detector'）
  AndroidProxyRepository({String channelName = 'proxy_detector'})
      : _channel = MethodChannel(channelName);

  /// テスト用のコンストラクタ（カスタムチャンネルを注入可能）
  AndroidProxyRepository.withChannel(MethodChannel channel)
      : _channel = channel;

  @override
  Future<ProxySettings> getProxySettings() async {
    try {
      final Map<dynamic, dynamic> result =
          await _channel.invokeMethod('getProxySettings');
      return ProxySettings.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw ProxyRepositoryException(
        'プロキシ設定の取得に失敗しました',
        e,
      );
    } catch (e) {
      throw ProxyRepositoryException(
        '予期しないエラーが発生しました',
        e,
      );
    }
  }

  @override
  Future<bool> isProxyEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isProxyEnabled');
      return result;
    } on PlatformException catch (e) {
      throw ProxyRepositoryException(
        'プロキシ状態の確認に失敗しました',
        e,
      );
    } catch (e) {
      throw ProxyRepositoryException(
        '予期しないエラーが発生しました',
        e,
      );
    }
  }

  @override
  Future<String> getProxyServer() async {
    try {
      final String result = await _channel.invokeMethod('getProxyServer');
      return result;
    } on PlatformException catch (e) {
      throw ProxyRepositoryException(
        'プロキシサーバー情報の取得に失敗しました',
        e,
      );
    } catch (e) {
      throw ProxyRepositoryException(
        '予期しないエラーが発生しました',
        e,
      );
    }
  }
}

