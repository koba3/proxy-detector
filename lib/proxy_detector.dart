/// Proxy Detector Library
/// 
/// このライブラリは、システムのプロキシ設定を検出するための
/// 疎結合で再利用可能なコンポーネントを提供します。
/// 
/// ## 使用例
/// 
/// ### 基本的な使用方法
/// 
/// ```dart
/// import 'package:proxy_detector/proxy_detector.dart';
/// 
/// // Windows用のリポジトリを使用してサービスを初期化
/// final proxyService = ProxyService(WindowsProxyRepository());
/// 
/// // プロキシ設定を取得
/// final settings = await proxyService.getProxySettings();
/// print('プロキシ有効: ${settings.isEnabled}');
/// print('プロキシサーバー: ${settings.proxyServer}');
/// ```
/// 
/// ### カスタムリポジトリの実装
/// 
/// ```dart
/// // モックリポジトリの例
/// class MockProxyRepository implements ProxyRepository {
///   @override
///   Future<ProxySettings> getProxySettings() async {
///     return ProxySettings(
///       isEnabled: true,
///       proxyServer: 'proxy.example.com:8080',
///       bypassList: 'localhost',
///       autoDetect: false,
///       autoConfigUrl: '',
///     );
///   }
///   
///   @override
///   Future<bool> isProxyEnabled() async => true;
///   
///   @override
///   Future<String> getProxyServer() async => 'proxy.example.com:8080';
/// }
/// 
/// // モックリポジトリを使用
/// final mockService = ProxyService(MockProxyRepository());
/// ```
/// 
/// ### 依存性注入パターン
/// 
/// ```dart
/// class MyApp extends StatelessWidget {
///   final ProxyService proxyService;
///   
///   const MyApp({required this.proxyService, Key? key}) : super(key: key);
///   
///   @override
///   Widget build(BuildContext context) {
///     // proxyServiceを使用してプロキシ設定を取得
///   }
/// }
/// 
/// void main() {
///   final proxyService = ProxyService(WindowsProxyRepository());
///   runApp(MyApp(proxyService: proxyService));
/// }
/// ```

library proxy_detector;

// Models
export 'models/proxy_settings.dart';

// Repositories
export 'repositories/proxy_repository.dart';
export 'repositories/windows_proxy_repository.dart';
export 'repositories/ios_proxy_repository.dart';
export 'repositories/android_proxy_repository.dart';
export 'repositories/platform_proxy_repository.dart';

// Services
export 'services/proxy_service.dart';

