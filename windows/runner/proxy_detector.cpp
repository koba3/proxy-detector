#include "proxy_detector.h"
#include <iostream>
#include <sstream>

ProxyInfo ProxyDetector::GetSystemProxySettings() {
    ProxyInfo info = {};
    
    // WinHTTPを使用してプロキシ設定を取得
    WINHTTP_CURRENT_USER_IE_PROXY_CONFIG config = {};
    
    if (WinHttpGetIEProxyConfigForCurrentUser(&config)) {
        info.isEnabled = (config.lpszProxy != nullptr);
        info.autoDetect = config.fAutoDetect;
        
        if (config.lpszProxy) {
            // プロキシサーバー情報を取得
            std::wstring proxyW(config.lpszProxy);
            info.proxyServer = std::string(proxyW.begin(), proxyW.end());
            GlobalFree(config.lpszProxy);
        }
        
        if (config.lpszAutoConfigUrl) {
            // 自動設定URLを取得
            std::wstring autoConfigW(config.lpszAutoConfigUrl);
            info.autoConfigUrl = std::string(autoConfigW.begin(), autoConfigW.end());
            GlobalFree(config.lpszAutoConfigUrl);
        }
        
        if (config.lpszProxyBypass) {
            // バイパスリストを取得
            std::wstring bypassW(config.lpszProxyBypass);
            info.bypassList = std::string(bypassW.begin(), bypassW.end());
            GlobalFree(config.lpszProxyBypass);
        }
    }
    
    return info;
}

std::vector<std::string> ProxyDetector::GetProxyServers() {
    std::vector<std::string> servers;
    ProxyInfo info = GetSystemProxySettings();
    
    if (info.isEnabled && !info.proxyServer.empty()) {
        // プロキシサーバー文字列を解析（複数のプロキシが設定されている場合）
        std::istringstream iss(info.proxyServer);
        std::string server;
        
        while (std::getline(iss, server, ';')) {
            if (!server.empty()) {
                servers.push_back(server);
            }
        }
    }
    
    return servers;
}

bool ProxyDetector::IsProxyEnabled() {
    ProxyInfo info = GetSystemProxySettings();
    return info.isEnabled;
}

std::string ProxyDetector::GetProxyServer() {
    ProxyInfo info = GetSystemProxySettings();
    return info.proxyServer;
}

std::string ProxyDetector::GetBypassList() {
    ProxyInfo info = GetSystemProxySettings();
    return info.bypassList;
}

bool ProxyDetector::IsAutoDetectEnabled() {
    ProxyInfo info = GetSystemProxySettings();
    return info.autoDetect;
}

std::string ProxyDetector::GetAutoConfigUrl() {
    ProxyInfo info = GetSystemProxySettings();
    return info.autoConfigUrl;
}
