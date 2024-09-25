import Foundation
import OwnIDCoreSDK
import WebKit

@MainActor
@objc class OwnIDHelper: NSObject {
    let webBridge = OwnID.CoreSDK.createWebViewBridge()
    
    @objc static func configure() {
        OwnID.CoreSDK.configure(appID: "xotvc7yff9clvn", userFacingSDK: info(), environment: "dev")
    }
    
    @objc func inject(webView: UIView) {
        if let webView = webView as? WKWebView {
            webBridge.injectInto(webView: webView)
        }
    }
    
    private static func info() -> OwnID.CoreSDK.SDKInformation {
        ("Integration", "3.5.0")
    }
}
