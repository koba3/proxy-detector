#ifndef PROXY_DETECTOR_H
#define PROXY_DETECTOR_H

#include <windows.h>
#include <winhttp.h>
#include <string>
#include <vector>

struct ProxyInfo {
    bool isEnabled;
    std::string proxyServer;
    std::string bypassList;
    bool autoDetect;
    std::string autoConfigUrl;
};

class ProxyDetector {
public:
    static ProxyInfo GetSystemProxySettings();
    static std::vector<std::string> GetProxyServers();
    static bool IsProxyEnabled();
    static std::string GetProxyServer();
    static std::string GetBypassList();
    static bool IsAutoDetectEnabled();
    static std::string GetAutoConfigUrl();
};

#endif // PROXY_DETECTOR_H
