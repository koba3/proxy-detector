// ignore_for_file: avoid_print

/// Proxy Detector の使用例
/// 
/// このファイルは、proxy_detectorライブラリの様々な使用方法を示します。

import '../lib/proxy_detector.dart';

void main() async {
  // 例1: 基本的な使用方法
  await example1BasicUsage();

  // 例2: 個別のメソッドを使用
  await example2IndividualMethods();

  // 例3: エラーハンドリング
  await example3ErrorHandling();

  // 例4: カスタムリポジトリの使用
  await example4CustomRepository();
}

/// 例1: 基本的な使用方法
Future<void> example1BasicUsage() async {
  print('=== 例1: 基本的な使用方法 ===');

  // WindowsProxyRepositoryを使用してProxyServiceを初期化
  final proxyService = ProxyService(WindowsProxyRepository());

  try {
    // プロキシ設定を取得
    final settings = await proxyService.getProxySettings();

    print('プロキシ有効: ${settings.isEnabled}');
    print('プロキシサーバー: ${settings.proxyServer}');
    print('バイパスリスト: ${settings.bypassList}');
    print('自動検出: ${settings.autoDetect}');
    print('自動設定URL: ${settings.autoConfigUrl}');
  } catch (e) {
    print('エラー: $e');
  }

  print('');
}

/// 例2: 個別のメソッドを使用
Future<void> example2IndividualMethods() async {
  print('=== 例2: 個別のメソッドを使用 ===');

  final proxyService = ProxyService(WindowsProxyRepository());

  try {
    // プロキシが有効かどうかを確認
    final isEnabled = await proxyService.isProxyEnabled();
    print('プロキシ有効: $isEnabled');

    if (isEnabled) {
      // プロキシサーバーを取得
      final server = await proxyService.getProxyServer();
      print('プロキシサーバー: $server');

      // プロキシが完全に設定されているか確認
      final isFullyConfigured = await proxyService.isProxyFullyConfigured();
      print('完全に設定済み: $isFullyConfigured');

      // プロキシ設定のサマリーを取得
      final summary = await proxyService.getProxySettingsSummary();
      print('サマリー: $summary');
    }
  } catch (e) {
    print('エラー: $e');
  }

  print('');
}

/// 例3: エラーハンドリング
Future<void> example3ErrorHandling() async {
  print('=== 例3: エラーハンドリング ===');

  final proxyService = ProxyService(WindowsProxyRepository());

  try {
    final settings = await proxyService.getProxySettings();
    print('プロキシ設定取得成功: ${settings.isEnabled}');
  } on ProxyServiceException catch (e) {
    // ProxyServiceExceptionを明示的にキャッチ
    print('プロキシサービスエラー: ${e.message}');
    if (e.originalError != null) {
      print('原因: ${e.originalError}');
    }
  } catch (e) {
    // その他のエラー
    print('予期しないエラー: $e');
  }

  print('');
}

/// 例4: カスタムリポジトリの使用
Future<void> example4CustomRepository() async {
  print('=== 例4: カスタムリポジトリの使用 ===');

  // モックリポジトリを使用（テストや開発時に便利）
  final mockService = ProxyService(MockProxyRepository());

  try {
    final settings = await mockService.getProxySettings();
    print('モックプロキシ有効: ${settings.isEnabled}');
    print('モックプロキシサーバー: ${settings.proxyServer}');
  } catch (e) {
    print('エラー: $e');
  }

  print('');
}

/// モックプロキシリポジトリ（テスト用）
class MockProxyRepository implements ProxyRepository {
  @override
  Future<ProxySettings> getProxySettings() async {
    // 遅延をシミュレート
    await Future.delayed(const Duration(milliseconds: 100));

    return const ProxySettings(
      isEnabled: true,
      proxyServer: 'mock-proxy.example.com:8080',
      bypassList: 'localhost;127.0.0.1',
      autoDetect: false,
      autoConfigUrl: 'http://proxy.example.com/proxy.pac',
    );
  }

  @override
  Future<bool> isProxyEnabled() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Future<String> getProxyServer() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return 'mock-proxy.example.com:8080';
  }
}

