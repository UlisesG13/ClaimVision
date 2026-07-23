import Flutter
import UIKit

class ScreenshotProtectionPlugin: NSObject, FlutterPlugin {
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.claimvision/screenshot_protection",
            binaryMessenger: registrar.messenger()
        )
        let instance = ScreenshotProtectionPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableScreenshotProtection":
            setSecure(true)
            result(true)
        case "disableScreenshotProtection":
            setSecure(false)
            result(true)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setSecure(_ secure: Bool) {
        if #available(iOS 13.0, *) {
            for window in UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap({ $0.windows })
            {
                window.layer.setValue(secure, forKey: "isSecure")
            }
        } else {
            for window in UIApplication.shared.windows {
                window.layer.setValue(secure, forKey: "isSecure")
            }
        }
    }
}
