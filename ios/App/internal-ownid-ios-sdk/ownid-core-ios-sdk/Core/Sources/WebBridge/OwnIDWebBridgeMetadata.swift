import Foundation

extension OwnID.CoreSDK {
    final class OwnIDWebBridgeMetadata: WebNamespace {
        struct JSCorrelation: Encodable {
            let correlationId: String
        }
        
        var name = JSNamespace.METADATA
        var actions: [JSAction] = [.get]
        
        func invoke(bridgeContext: OwnID.CoreSDK.OwnIDWebBridgeContext, action: OwnID.CoreSDK.JSAction, params: String, metadata: OwnID.CoreSDK.JSMetadata?, completion: @escaping (String) -> Void) {
            let JSCorrelation = JSCorrelation(correlationId: OwnID.CoreSDK.LoggerConstants.instanceID.uuidString)
            guard let jsonData = try? JSONEncoder().encode(JSCorrelation),
                  let result = String(data: jsonData, encoding: String.Encoding.utf8) else {
                completion("")
                return
            }
            completion(result)
        }
    }
}
