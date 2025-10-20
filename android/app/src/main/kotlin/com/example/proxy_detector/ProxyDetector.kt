package com.example.proxy_detector

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.ProxyInfo
import android.os.Build
import java.net.InetSocketAddress
import java.net.Proxy

/**
 * Androidシステムのプロキシ設定を検出するクラス
 */
class ProxyDetector(private val context: Context) {

    /**
     * システムのプロキシ設定を取得
     */
    fun getSystemProxySettings(): Map<String, Any> {
        val proxyInfo = getProxyInfo()
        
        return mapOf(
            "isEnabled" to proxyInfo.isEnabled,
            "proxyServer" to proxyInfo.proxyServer,
            "bypassList" to proxyInfo.bypassList,
            "autoDetect" to proxyInfo.autoDetect,
            "autoConfigUrl" to proxyInfo.autoConfigUrl
        )
    }

    /**
     * プロキシが有効かどうかを確認
     */
    fun isProxyEnabled(): Boolean {
        return getProxyInfo().isEnabled
    }

    /**
     * プロキシサーバー情報を取得
     */
    fun getProxyServer(): String {
        return getProxyInfo().proxyServer
    }

    /**
     * プロキシ情報を取得する内部メソッド
     */
    private fun getProxyInfo(): ProxyInfoData {
        var isEnabled = false
        var proxyServer = ""
        var bypassList = ""
        val autoDetect = false
        var autoConfigUrl = ""

        try {
            // Android 6.0 (API 23) 以降の方法
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val activeNetwork: Network? = connectivityManager.activeNetwork
                
                if (activeNetwork != null) {
                    val linkProperties = connectivityManager.getLinkProperties(activeNetwork)
                    val httpProxy = linkProperties?.httpProxy
                    
                    if (httpProxy != null && httpProxy != android.net.ProxyInfo.buildDirectProxy("", 0)) {
                        isEnabled = true
                        
                        // プロキシホストとポートを取得
                        val host = httpProxy.host
                        val port = httpProxy.port
                        
                        if (host != null && host.isNotEmpty() && port > 0) {
                            proxyServer = "$host:$port"
                        }
                        
                        // バイパスリストを取得
                        val exclusionList = httpProxy.exclusionList
                        if (exclusionList != null && exclusionList.isNotEmpty()) {
                            bypassList = exclusionList.joinToString(";")
                        }
                        
                        // PAC URLを取得
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            val pacFileUrl = httpProxy.pacFileUrl
                            if (pacFileUrl != null && pacFileUrl.toString().isNotEmpty()) {
                                autoConfigUrl = pacFileUrl.toString()
                            }
                        }
                    }
                }
            } else {
                // Android 5.x (API 21-22) の方法
                @Suppress("DEPRECATION")
                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                @Suppress("DEPRECATION")
                val activeNetworkInfo = connectivityManager.activeNetworkInfo
                
                if (activeNetworkInfo != null && activeNetworkInfo.isConnected) {
                    // システムプロパティから取得を試みる
                    val host = System.getProperty("http.proxyHost")
                    val port = System.getProperty("http.proxyPort")
                    
                    if (!host.isNullOrEmpty() && !port.isNullOrEmpty()) {
                        isEnabled = true
                        proxyServer = "$host:$port"
                    }
                }
            }
        } catch (e: Exception) {
            // エラーが発生した場合は空の設定を返す
            e.printStackTrace()
        }

        return ProxyInfoData(
            isEnabled = isEnabled,
            proxyServer = proxyServer,
            bypassList = bypassList,
            autoDetect = autoDetect,
            autoConfigUrl = autoConfigUrl
        )
    }

    /**
     * グローバルプロキシ設定を取得（システム設定）
     * 注意: Android 5.0以降では非推奨
     */
    @Suppress("DEPRECATION")
    private fun getGlobalProxySettings(): ProxyInfoData {
        var isEnabled = false
        var proxyServer = ""
        
        try {
            val host = System.getProperty("http.proxyHost")
            val port = System.getProperty("http.proxyPort")
            
            if (!host.isNullOrEmpty() && !port.isNullOrEmpty()) {
                isEnabled = true
                proxyServer = "$host:$port"
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return ProxyInfoData(
            isEnabled = isEnabled,
            proxyServer = proxyServer,
            bypassList = "",
            autoDetect = false,
            autoConfigUrl = ""
        )
    }

    /**
     * 詳細なプロキシ情報を取得
     */
    fun getDetailedProxySettings(): Map<String, Any> {
        val details = mutableMapOf<String, Any>()
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                val activeNetwork: Network? = connectivityManager.activeNetwork
                
                if (activeNetwork != null) {
                    val linkProperties = connectivityManager.getLinkProperties(activeNetwork)
                    val httpProxy = linkProperties?.httpProxy
                    
                    if (httpProxy != null) {
                        details["host"] = httpProxy.host ?: ""
                        details["port"] = httpProxy.port
                        details["exclusionList"] = httpProxy.exclusionList?.toList() ?: emptyList<String>()
                        
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                            val pacFileUrl = httpProxy.pacFileUrl
                            if (pacFileUrl != null) {
                                details["pacFileUrl"] = pacFileUrl.toString()
                            }
                        }
                    }
                    
                    // ネットワーク情報も追加
                    val capabilities = connectivityManager.getNetworkCapabilities(activeNetwork)
                    if (capabilities != null) {
                        details["hasInternet"] = capabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                        details["hasWifi"] = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
                        details["hasCellular"] = capabilities.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR)
                    }
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        return details
    }

    /**
     * プロキシ情報を格納するデータクラス
     */
    private data class ProxyInfoData(
        val isEnabled: Boolean,
        val proxyServer: String,
        val bypassList: String,
        val autoDetect: Boolean,
        val autoConfigUrl: String
    )
}

