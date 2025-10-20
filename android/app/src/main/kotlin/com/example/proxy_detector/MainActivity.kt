package com.example.proxy_detector

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "proxy_detector"
    private lateinit var proxyDetector: ProxyDetector

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        proxyDetector = ProxyDetector(applicationContext)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getProxySettings" -> {
                    try {
                        val settings = proxyDetector.getSystemProxySettings()
                        result.success(settings)
                    } catch (e: Exception) {
                        result.error("PROXY_ERROR", "プロキシ設定の取得に失敗しました: ${e.message}", null)
                    }
                }
                
                "isProxyEnabled" -> {
                    try {
                        val enabled = proxyDetector.isProxyEnabled()
                        result.success(enabled)
                    } catch (e: Exception) {
                        result.error("PROXY_ERROR", "プロキシ状態の確認に失敗しました: ${e.message}", null)
                    }
                }
                
                "getProxyServer" -> {
                    try {
                        val server = proxyDetector.getProxyServer()
                        result.success(server)
                    } catch (e: Exception) {
                        result.error("PROXY_ERROR", "プロキシサーバー情報の取得に失敗しました: ${e.message}", null)
                    }
                }
                
                "getDetailedProxySettings" -> {
                    try {
                        val details = proxyDetector.getDetailedProxySettings()
                        result.success(details)
                    } catch (e: Exception) {
                        result.error("PROXY_ERROR", "詳細設定の取得に失敗しました: ${e.message}", null)
                    }
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
