#include "flutter_window.h"

#include <optional>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include "flutter/generated_plugin_registrant.h"
#include "proxy_detector.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  
  // プロキシ検出用のメソッドチャンネルを設定
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      flutter_controller_->engine()->messenger(), "proxy_detector",
      &flutter::StandardMethodCodec::GetInstance());
  
  channel->SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (call.method_name() == "getProxySettings") {
          try {
            ProxyInfo info = ProxyDetector::GetSystemProxySettings();
            
            flutter::EncodableMap proxyMap;
            proxyMap[flutter::EncodableValue("isEnabled")] = flutter::EncodableValue(info.isEnabled);
            proxyMap[flutter::EncodableValue("proxyServer")] = flutter::EncodableValue(info.proxyServer);
            proxyMap[flutter::EncodableValue("bypassList")] = flutter::EncodableValue(info.bypassList);
            proxyMap[flutter::EncodableValue("autoDetect")] = flutter::EncodableValue(info.autoDetect);
            proxyMap[flutter::EncodableValue("autoConfigUrl")] = flutter::EncodableValue(info.autoConfigUrl);
            
            result->Success(flutter::EncodableValue(proxyMap));
          } catch (const std::exception& e) {
            result->Error("PROXY_ERROR", e.what());
          }
        } else if (call.method_name() == "isProxyEnabled") {
          try {
            bool enabled = ProxyDetector::IsProxyEnabled();
            result->Success(flutter::EncodableValue(enabled));
          } catch (const std::exception& e) {
            result->Error("PROXY_ERROR", e.what());
          }
        } else if (call.method_name() == "getProxyServer") {
          try {
            std::string server = ProxyDetector::GetProxyServer();
            result->Success(flutter::EncodableValue(server));
          } catch (const std::exception& e) {
            result->Error("PROXY_ERROR", e.what());
          }
        } else {
          result->NotImplemented();
        }
      });
  
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
