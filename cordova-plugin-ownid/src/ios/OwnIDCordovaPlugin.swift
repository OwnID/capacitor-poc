import Foundation
import WebKit
import OwnIDCoreSDK

@objc(OwnIDCordovaPlugin) class OwnIDCordovaPlugin: CDVPlugin {
    let webBridge = OwnID.CoreSDK.createWebViewBridge()
    
    override func pluginInitialize() {
        super.pluginInitialize()

        OwnID.CoreSDK.configure(userFacingSDK: Self.info())

        if let webView = webView as? WKWebView {
            webBridge.injectInto(webView: webView)
        }
    }

    private static func info() -> OwnID.CoreSDK.SDKInformation {
        ("OwnIDCordovaPlugin", "3.5.0")
    }
}
