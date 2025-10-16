import 'package:flutter/services.dart';

class ProxyService {
  static const MethodChannel _channel = MethodChannel('proxy_detector');

  /// システムのプロキシ設定を取得
  static Future<Map<String, dynamic>> getProxySettings() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getProxySettings');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('プロキシ設定の取得に失敗しました: ${e.message}');
    }
  }

  /// プロキシが有効かどうかを確認
  static Future<bool> isProxyEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isProxyEnabled');
      return result;
    } on PlatformException catch (e) {
      throw Exception('プロキシ状態の確認に失敗しました: ${e.message}');
    }
  }

  /// プロキシサーバー情報を取得
  static Future<String> getProxyServer() async {
    try {
      final String result = await _channel.invokeMethod('getProxyServer');
      return result;
    } on PlatformException catch (e) {
      throw Exception('プロキシサーバー情報の取得に失敗しました: ${e.message}');
    }
  }
}
