import 'dart:convert';

/// プロキシ認証情報を表すデータモデル
/// 
/// このクラスは、ユーザーが入力したプロキシ認証情報を管理します。
/// セキュリティ上の理由から、システムから自動取得することはできないため、
/// ユーザーが手動で入力した情報を安全に保存・管理します。
class ProxyCredentials {
  /// ユーザー名
  final String username;

  /// パスワード（暗号化して保存することを推奨）
  final String password;

  /// 認証方式（Basic、Digest、NTLM等）
  final ProxyAuthType authType;

  const ProxyCredentials({
    required this.username,
    required this.password,
    this.authType = ProxyAuthType.basic,
  });

  /// 空の認証情報（認証なし）
  factory ProxyCredentials.empty() {
    return const ProxyCredentials(
      username: '',
      password: '',
      authType: ProxyAuthType.none,
    );
  }

  /// Mapから認証情報を作成
  factory ProxyCredentials.fromMap(Map<String, dynamic> map) {
    return ProxyCredentials(
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      authType: ProxyAuthType.fromString(
        map['authType'] as String? ?? 'none'
      ),
    );
  }

  /// 認証情報をMapに変換
  /// 
  /// 注意: パスワードを平文で保存しないでください
  /// 暗号化してから保存することを推奨します
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password, // 実際には暗号化すべき
      'authType': authType.name,
    };
  }

  /// 認証情報が設定されているか確認
  bool get hasCredentials {
    return username.isNotEmpty && password.isNotEmpty;
  }

  /// Basic認証用のヘッダー値を生成
  /// 
  /// Returns: "Basic base64(username:password)" 形式の文字列
  String toBasicAuthHeader() {
    if (!hasCredentials) return '';
    
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  /// 認証情報をコピーして一部の値を変更
  ProxyCredentials copyWith({
    String? username,
    String? password,
    ProxyAuthType? authType,
  }) {
    return ProxyCredentials(
      username: username ?? this.username,
      password: password ?? this.password,
      authType: authType ?? this.authType,
    );
  }

  @override
  String toString() {
    // パスワードをマスク
    final maskedPassword = password.isNotEmpty ? '********' : '';
    return 'ProxyCredentials(username: $username, password: $maskedPassword, '
        'authType: ${authType.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProxyCredentials &&
        other.username == username &&
        other.password == password &&
        other.authType == authType;
  }

  @override
  int get hashCode {
    return Object.hash(username, password, authType);
  }
}

/// プロキシ認証方式
enum ProxyAuthType {
  /// 認証なし
  none,
  
  /// Basic認証
  basic,
  
  /// Digest認証
  digest,
  
  /// NTLM認証（Windows統合認証）
  ntlm,
  
  /// Kerberos認証
  kerberos;

  /// 文字列から認証方式を取得
  static ProxyAuthType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'basic':
        return ProxyAuthType.basic;
      case 'digest':
        return ProxyAuthType.digest;
      case 'ntlm':
        return ProxyAuthType.ntlm;
      case 'kerberos':
        return ProxyAuthType.kerberos;
      case 'none':
      default:
        return ProxyAuthType.none;
    }
  }
}

