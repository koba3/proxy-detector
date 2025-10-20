import Foundation
import SystemConfiguration

/// プロキシ設定情報を格納する構造体
struct ProxyInfo {
    var isEnabled: Bool
    var proxyServer: String
    var bypassList: String
    var autoDetect: Bool
    var autoConfigUrl: String
}

/// iOS システムのプロキシ設定を検出するクラス
class ProxyDetector {
    
    /// システムのプロキシ設定を取得
    /// - Returns: プロキシ設定情報の辞書
    static func getSystemProxySettings() -> [String: Any] {
        let info = getProxyInfo()
        
        return [
            "isEnabled": info.isEnabled,
            "proxyServer": info.proxyServer,
            "bypassList": info.bypassList,
            "autoDetect": info.autoDetect,
            "autoConfigUrl": info.autoConfigUrl
        ]
    }
    
    /// プロキシが有効かどうかを確認
    /// - Returns: プロキシが有効な場合は true
    static func isProxyEnabled() -> Bool {
        let info = getProxyInfo()
        return info.isEnabled
    }
    
    /// プロキシサーバー情報を取得
    /// - Returns: プロキシサーバーのアドレス
    static func getProxyServer() -> String {
        let info = getProxyInfo()
        return info.proxyServer
    }
    
    /// プロキシ情報を取得する内部メソッド
    /// - Returns: ProxyInfo 構造体
    private static func getProxyInfo() -> ProxyInfo {
        var info = ProxyInfo(
            isEnabled: false,
            proxyServer: "",
            bypassList: "",
            autoDetect: false,
            autoConfigUrl: ""
        )
        
        // システムのプロキシ設定を取得
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return info
        }
        
        // HTTPプロキシの有効状態を確認
        if let httpEnable = proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Int,
           httpEnable == 1 {
            info.isEnabled = true
            
            // HTTPプロキシサーバーを取得
            if let httpProxy = proxySettings[kCFNetworkProxiesHTTPProxy as String] as? String,
               let httpPort = proxySettings[kCFNetworkProxiesHTTPPort as String] as? Int {
                info.proxyServer = "\(httpProxy):\(httpPort)"
            }
        }
        
        // HTTPSプロキシもチェック（HTTPと異なる場合）
        if let httpsEnable = proxySettings[kCFNetworkProxiesHTTPSEnable as String] as? Int,
           httpsEnable == 1,
           info.proxyServer.isEmpty {
            if let httpsProxy = proxySettings[kCFNetworkProxiesHTTPSProxy as String] as? String,
               let httpsPort = proxySettings[kCFNetworkProxiesHTTPSPort as String] as? Int {
                info.proxyServer = "\(httpsProxy):\(httpsPort)"
                info.isEnabled = true
            }
        }
        
        // SOCKSプロキシもチェック
        if let socksEnable = proxySettings[kCFNetworkProxiesSOCKSEnable as String] as? Int,
           socksEnable == 1,
           info.proxyServer.isEmpty {
            if let socksProxy = proxySettings[kCFNetworkProxiesSOCKSProxy as String] as? String,
               let socksPort = proxySettings[kCFNetworkProxiesSOCKSPort as String] as? Int {
                info.proxyServer = "socks://\(socksProxy):\(socksPort)"
                info.isEnabled = true
            }
        }
        
        // バイパスリストを取得
        if let exceptionsList = proxySettings[kCFNetworkProxiesExceptionsList as String] as? [String] {
            info.bypassList = exceptionsList.joined(separator: ";")
        }
        
        // 自動プロキシ検出（WPAD）
        if let autoDiscovery = proxySettings[kCFNetworkProxiesProxyAutoDiscoveryEnable as String] as? Int,
           autoDiscovery == 1 {
            info.autoDetect = true
        }
        
        // 自動設定URL（PAC）
        if let autoConfigEnable = proxySettings[kCFNetworkProxiesProxyAutoConfigEnable as String] as? Int,
           autoConfigEnable == 1,
           let autoConfigURL = proxySettings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String {
            info.autoConfigUrl = autoConfigURL
        }
        
        return info
    }
    
    /// 特定のURLに対するプロキシ設定を取得
    /// - Parameter urlString: チェックするURL
    /// - Returns: そのURLに適用されるプロキシ情報
    static func getProxyForURL(_ urlString: String) -> [String: Any]? {
        guard let url = URL(string: urlString),
              let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() else {
            return nil
        }
        
        let proxies = CFNetworkCopyProxiesForURL(url as CFURL, proxySettings).takeRetainedValue() as? [[String: Any]]
        
        return proxies?.first
    }
    
    /// 複数のプロキシタイプを含む詳細情報を取得
    /// - Returns: HTTPプロキシ、HTTPSプロキシ、SOCKSプロキシなどの詳細情報
    static func getDetailedProxySettings() -> [String: Any] {
        var details: [String: Any] = [:]
        
        guard let proxySettings = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as? [String: Any] else {
            return details
        }
        
        // HTTPプロキシ
        if let httpEnable = proxySettings[kCFNetworkProxiesHTTPEnable as String] as? Int,
           httpEnable == 1 {
            var httpInfo: [String: Any] = ["enabled": true]
            if let httpProxy = proxySettings[kCFNetworkProxiesHTTPProxy as String] as? String {
                httpInfo["host"] = httpProxy
            }
            if let httpPort = proxySettings[kCFNetworkProxiesHTTPPort as String] as? Int {
                httpInfo["port"] = httpPort
            }
            details["http"] = httpInfo
        }
        
        // HTTPSプロキシ
        if let httpsEnable = proxySettings[kCFNetworkProxiesHTTPSEnable as String] as? Int,
           httpsEnable == 1 {
            var httpsInfo: [String: Any] = ["enabled": true]
            if let httpsProxy = proxySettings[kCFNetworkProxiesHTTPSProxy as String] as? String {
                httpsInfo["host"] = httpsProxy
            }
            if let httpsPort = proxySettings[kCFNetworkProxiesHTTPSPort as String] as? Int {
                httpsInfo["port"] = httpsPort
            }
            details["https"] = httpsInfo
        }
        
        // SOCKSプロキシ
        if let socksEnable = proxySettings[kCFNetworkProxiesSOCKSEnable as String] as? Int,
           socksEnable == 1 {
            var socksInfo: [String: Any] = ["enabled": true]
            if let socksProxy = proxySettings[kCFNetworkProxiesSOCKSProxy as String] as? String {
                socksInfo["host"] = socksProxy
            }
            if let socksPort = proxySettings[kCFNetworkProxiesSOCKSPort as String] as? Int {
                socksInfo["port"] = socksPort
            }
            details["socks"] = socksInfo
        }
        
        // FTPプロキシ
        if let ftpEnable = proxySettings[kCFNetworkProxiesFTPEnable as String] as? Int,
           ftpEnable == 1 {
            var ftpInfo: [String: Any] = ["enabled": true]
            if let ftpProxy = proxySettings[kCFNetworkProxiesFTPProxy as String] as? String {
                ftpInfo["host"] = ftpProxy
            }
            if let ftpPort = proxySettings[kCFNetworkProxiesFTPPort as String] as? Int {
                ftpInfo["port"] = ftpPort
            }
            details["ftp"] = ftpInfo
        }
        
        // バイパスリスト
        if let exceptionsList = proxySettings[kCFNetworkProxiesExceptionsList as String] as? [String] {
            details["bypassList"] = exceptionsList
        }
        
        // 自動検出とPAC
        if let autoDiscovery = proxySettings[kCFNetworkProxiesProxyAutoDiscoveryEnable as String] as? Int {
            details["autoDetect"] = (autoDiscovery == 1)
        }
        
        if let autoConfigURL = proxySettings[kCFNetworkProxiesProxyAutoConfigURLString as String] as? String {
            details["autoConfigUrl"] = autoConfigURL
        }
        
        return details
    }
}

