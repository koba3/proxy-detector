import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let proxyChannel = FlutterMethodChannel(
      name: "proxy_detector",
      binaryMessenger: controller.binaryMessenger
    )
    
    proxyChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "getProxySettings":
        let settings = ProxyDetector.getSystemProxySettings()
        result(settings)
        
      case "isProxyEnabled":
        let enabled = ProxyDetector.isProxyEnabled()
        result(enabled)
        
      case "getProxyServer":
        let server = ProxyDetector.getProxyServer()
        result(server)
        
      case "getDetailedProxySettings":
        let details = ProxyDetector.getDetailedProxySettings()
        result(details)
        
      case "getProxyForURL":
        if let args = call.arguments as? [String: Any],
           let urlString = args["url"] as? String {
          let proxyInfo = ProxyDetector.getProxyForURL(urlString)
          result(proxyInfo ?? [:])
        } else {
          result(FlutterError(
            code: "INVALID_ARGUMENT",
            message: "URL is required",
            details: nil
          ))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
