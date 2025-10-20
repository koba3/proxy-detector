import 'package:flutter/material.dart';
import 'models/proxy_settings.dart';
import 'repositories/platform_proxy_repository.dart';
import 'services/proxy_service.dart';

void main() {
  runApp(const ProxyDetectorApp());
}

class ProxyDetectorApp extends StatelessWidget {
  const ProxyDetectorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Windows プロキシ設定検出アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ProxyDetectorPage(),
    );
  }
}

class ProxyDetectorPage extends StatefulWidget {
  const ProxyDetectorPage({super.key});

  @override
  State<ProxyDetectorPage> createState() => _ProxyDetectorPageState();
}

class _ProxyDetectorPageState extends State<ProxyDetectorPage> {
  late final ProxyService _proxyService;
  ProxySettings? _proxySettings;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // 依存性注入: プラットフォームに応じたリポジトリを自動選択
    try {
      _proxyService = ProxyService(PlatformProxyRepository.create());
      _loadProxySettings();
    } catch (e) {
      setState(() {
        _error = 'このプラットフォームはサポートされていません: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProxySettings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final settings = await _proxyService.getProxySettings();
      setState(() {
        _proxySettings = settings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Windows プロキシ設定検出'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProxySettings,
            tooltip: '設定を再読み込み',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('プロキシ設定を読み込み中...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProxySettings,
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }

    if (_proxySettings == null) {
      return const Center(
        child: Text('プロキシ設定が見つかりません'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildProxyDetailsCard(),
          const SizedBox(height: 16),
          _buildAutoConfigCard(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isEnabled = _proxySettings!.isEnabled;
    final autoDetect = _proxySettings!.autoDetect;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isEnabled ? Icons.check_circle : Icons.cancel,
                  color: isEnabled ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  'プロキシ設定状態',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('プロキシ有効', isEnabled ? 'はい' : 'いいえ'),
            _buildInfoRow('自動検出', autoDetect ? 'はい' : 'いいえ'),
          ],
        ),
      ),
    );
  }

  Widget _buildProxyDetailsCard() {
    final proxyServer = _proxySettings!.proxyServer;
    final bypassList = _proxySettings!.bypassList;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'プロキシ詳細',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('プロキシサーバー', proxyServer.isEmpty ? '設定なし' : proxyServer),
            if (bypassList.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow('バイパスリスト', bypassList),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAutoConfigCard() {
    final autoConfigUrl = _proxySettings!.autoConfigUrl;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '自動設定',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('自動設定URL', autoConfigUrl.isEmpty ? '設定なし' : autoConfigUrl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}