/// プロキシ設定を表すデータモデル
/// 
/// このクラスはプラットフォーム非依存で、どのプロジェクトでも再利用可能です。
class ProxySettings {
  /// プロキシが有効かどうか
  final bool isEnabled;

  /// プロキシサーバーのアドレス（例: "proxy.example.com:8080"）
  final String proxyServer;

  /// プロキシをバイパスするアドレスのリスト
  final String bypassList;

  /// プロキシの自動検出が有効かどうか
  final bool autoDetect;

  /// 自動設定スクリプトのURL（PAC ファイル）
  final String autoConfigUrl;

  const ProxySettings({
    required this.isEnabled,
    required this.proxyServer,
    required this.bypassList,
    required this.autoDetect,
    required this.autoConfigUrl,
  });

  /// 空のプロキシ設定（プロキシが無効な状態）
  factory ProxySettings.empty() {
    return const ProxySettings(
      isEnabled: false,
      proxyServer: '',
      bypassList: '',
      autoDetect: false,
      autoConfigUrl: '',
    );
  }

  /// Mapからプロキシ設定を作成
  factory ProxySettings.fromMap(Map<String, dynamic> map) {
    return ProxySettings(
      isEnabled: map['isEnabled'] as bool? ?? false,
      proxyServer: map['proxyServer'] as String? ?? '',
      bypassList: map['bypassList'] as String? ?? '',
      autoDetect: map['autoDetect'] as bool? ?? false,
      autoConfigUrl: map['autoConfigUrl'] as String? ?? '',
    );
  }

  /// プロキシ設定をMapに変換
  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'proxyServer': proxyServer,
      'bypassList': bypassList,
      'autoDetect': autoDetect,
      'autoConfigUrl': autoConfigUrl,
    };
  }

  /// プロキシ設定をコピーして一部の値を変更
  ProxySettings copyWith({
    bool? isEnabled,
    String? proxyServer,
    String? bypassList,
    bool? autoDetect,
    String? autoConfigUrl,
  }) {
    return ProxySettings(
      isEnabled: isEnabled ?? this.isEnabled,
      proxyServer: proxyServer ?? this.proxyServer,
      bypassList: bypassList ?? this.bypassList,
      autoDetect: autoDetect ?? this.autoDetect,
      autoConfigUrl: autoConfigUrl ?? this.autoConfigUrl,
    );
  }

  @override
  String toString() {
    return 'ProxySettings(isEnabled: $isEnabled, proxyServer: $proxyServer, '
        'bypassList: $bypassList, autoDetect: $autoDetect, '
        'autoConfigUrl: $autoConfigUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProxySettings &&
        other.isEnabled == isEnabled &&
        other.proxyServer == proxyServer &&
        other.bypassList == bypassList &&
        other.autoDetect == autoDetect &&
        other.autoConfigUrl == autoConfigUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      isEnabled,
      proxyServer,
      bypassList,
      autoDetect,
      autoConfigUrl,
    );
  }
}

