import Foundation

extension OwnID.CoreSDK {
    final class OwnIDWebBridgeStorage: WebNamespace {
        struct JSStorage: Codable {
            let loginId: String
            let authMethod: String?
        }
        
        var name = JSNamespace.STORAGE
        var actions: [JSAction] = [.setLastUser, .getLastUser]
        
        func invoke(bridgeContext: OwnID.CoreSDK.OwnIDWebBridgeContext, action: OwnID.CoreSDK.JSAction, params: String, metadata: OwnID.CoreSDK.JSMetadata?, completion: @escaping (String) -> Void) {
            switch action {
            case .setLastUser:
                do {
                    let jsonData = params.data(using: .utf8) ?? Data()
                    let loginIdSaver = try JSONDecoder().decode(JSStorage.self, from: jsonData)
                    
                    let authType = AuthType(rawValue: loginIdSaver.authMethod ?? "")
                    LoginIdSaver.save(loginId: loginIdSaver.loginId, authMethod: AuthMethod.authMethod(from: authType))
                    
                    completion("{}")
                } catch {
                    let errorModel = OwnID.CoreSDK.UserErrorModel(message: error.localizedDescription)
                    handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                    
                    completion(handleErrorResult(errorMessage: error.localizedDescription))
                }
            case .getLastUser:
                if let loginId = DefaultsLoginIdSaver.loginId(), !loginId.isEmpty {
                    let authMethod = LoginIdDataSaver.loginIdData(from: loginId)?.authMethod
                    
                    let storage = JSStorage(loginId: loginId, authMethod: authMethod?.rawValue)
                    
                    do {
                        let jsonData = try JSONEncoder().encode(storage)
                        let result = String(data: jsonData, encoding: .utf8)
                        completion(result ?? "{}")
                    } catch {
                        let errorModel = OwnID.CoreSDK.UserErrorModel(message: error.localizedDescription)
                        handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                        
                        completion(handleErrorResult(errorMessage: error.localizedDescription))
                    }
                } else {
                    completion("{}")
                }
            default:
                break
            }
        }
        
        private func handleError(bridgeContext: OwnIDWebBridgeContext, errorModel: OwnID.CoreSDK.UserErrorModel) {
            bridgeContext.resultPublisher?.send(WebFlowResult.error(error: OwnID.CoreSDK.Error.userError(errorModel: errorModel)))
            ErrorWrapper(error: .userError(errorModel: errorModel), type: Self.self).log()
        }
        
        private func handleErrorResult(errorMessage: String) -> String {
            let error = JSError(type: String(describing: Self.self),
                                errorMessage: errorMessage,
                                errorCode: "ownIdWebViewBridgeStorageError")
            guard let jsonData = try? JSONEncoder().encode(error),
                  let errorString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return "{}"
            }
            return errorString
        }
    }
}
