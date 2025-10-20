import 'dart:io';
import 'package:flutter/foundation.dart';
import 'proxy_repository.dart';
import 'windows_proxy_repository.dart';
import 'ios_proxy_repository.dart';
import 'android_proxy_repository.dart';

/// プラットフォームに応じて適切なProxyRepositoryを作成するファクトリークラス
class PlatformProxyRepository {
  /// 現在のプラットフォームに適したProxyRepositoryを作成
  /// 
  /// - Windows: WindowsProxyRepository
  /// - iOS: IOSProxyRepository
  /// - Android: AndroidProxyRepository
  /// - その他: UnsupportedError をスロー
  /// 
  /// Returns: プラットフォーム固有のProxyRepository実装
  /// Throws: UnsupportedError サポートされていないプラットフォームの場合
  static ProxyRepository create() {
    if (kIsWeb) {
      throw UnsupportedError(
        'Webプラットフォームではプロキシ検出がサポートされていません。'
        'カスタムリポジトリを実装してください。'
      );
    }
    
    if (Platform.isWindows) {
      return WindowsProxyRepository();
    } else if (Platform.isIOS) {
      return IOSProxyRepository();
    } else if (Platform.isAndroid) {
      return AndroidProxyRepository();
    } else if (Platform.isMacOS) {
      // macOSはiOSと同じSystem Configuration frameworkを使用できる
      // ただし、別途実装が必要な場合は分岐させる
      throw UnsupportedError(
        'macOSはまだサポートされていません。'
        'macOS用のリポジトリを実装するか、IOSProxyRepositoryを参考にしてください。'
      );
    } else if (Platform.isLinux) {
      throw UnsupportedError(
        'Linuxはまだサポートされていません。'
        '環境変数（HTTP_PROXY等）を読み取るカスタムリポジトリを実装してください。'
      );
    }
    
    throw UnsupportedError(
      '不明なプラットフォームです: ${Platform.operatingSystem}'
    );
  }
  
  /// プラットフォームがサポートされているか確認
  /// 
  /// Returns: サポートされている場合は true
  static bool isSupported() {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isIOS || Platform.isAndroid;
  }
  
  /// 現在のプラットフォーム名を取得
  /// 
  /// Returns: プラットフォーム名（例: "Windows", "iOS"）
  static String getPlatformName() {
    if (kIsWeb) return 'Web';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    return Platform.operatingSystem;
  }
}

