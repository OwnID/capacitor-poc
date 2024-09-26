import WebKit
import Combine

enum OwnIDWebBridgeFlowError: Error {
    case wrongData
}

extension OwnIDWebBridgeFlowError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .wrongData:
            return OwnID.CoreSDK.ErrorMessage.dataIsMissingError()
        }
    }
}

extension OwnID.CoreSDK {
    enum WebFlowResult: WebBridgeResult {
        case accountNotFound(loginId: String, authToken: String?, ownIdData: String?)
        case login(session: String, loginId: String, authToken: String)
        case close
        case error(error: OwnID.CoreSDK.Error)
        
        var description: String {
            switch self {
            case .accountNotFound:
                return "accountNotFound"
            case .login:
                return "login"
            case .close:
                return "close"
            case .error(let error):
                return "error \(error.errorMessage)"
            }
        }
    }
    
    final class OwnIDWebBridgeFlow: WebNamespace {     
        var name = JSNamespace.FLOW
        var actions: [JSAction] = [.onAccountNotFound, .onLogin, .onClose, .onError]
        
        private var authManager: AuthManager?
        
        func invoke(bridgeContext: OwnIDWebBridgeContext,
                    action: OwnID.CoreSDK.JSAction,
                    params: String,
                    metadata: JSMetadata?,
                    completion: @escaping (_ result: String) -> Void) {
            switch action {
            case .onClose:
                bridgeContext.resultPublisher?.send(WebFlowResult.close)
                completion("{}")
            case .onError:
                do {
                    let jsonData = params.data(using: .utf8) ?? Data()
                    let error = try JSONDecoder().decode(JSError.self, from: jsonData)
                    let errorModel = OwnID.CoreSDK.UserErrorModel(code: error.errorCode,
                                                                  message: error.errorMessage,
                                                                  userMessage: error.errorMessage)
                    handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                } catch {
                    let message = OwnID.CoreSDK.ErrorMessage.dataIsMissingError()
                    let errorModel = OwnID.CoreSDK.UserErrorModel(message: message)
                    handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                }
                completion("{}")
            case .onAccountNotFound:
                do {
                    let jsonData = params.data(using: .utf8) ?? Data()
                    let authDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
                    
                    let loginId = authDict["loginId"] as? String ?? ""
                    let authToken = convertValue(dict: authDict, key: "authToken")
                    let ownIdData = convertValue(dict: authDict, key: "ownIdData")
                    
                    bridgeContext.resultPublisher?.send(WebFlowResult.accountNotFound(loginId: loginId,
                                                                                      authToken: authToken,
                                                                                      ownIdData: ownIdData))
                    completion("{}")
                } catch {
                    let errorModel = OwnID.CoreSDK.UserErrorModel(message: error.localizedDescription)
                    handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                    
                    completion(handleErrorResult(errorMessage: error.localizedDescription))
                }
            case .onLogin:
                do {
                    let jsonData = params.data(using: .utf8) ?? Data()
                    let authDict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] ?? [:]
                    
                    let session = convertValue(dict: authDict, key: "session") ?? ""
                    guard let metadata = authDict["metadata"] as? [String: Any],
                          let loginId = convertValue(dict: metadata, key: "loginId"),
                          let authToken = convertValue(dict: metadata, key: "authToken") else {
                        throw OwnIDWebBridgeFlowError.wrongData
                    }
                    
                    bridgeContext.resultPublisher?.send(WebFlowResult.login(session: session,
                                                                            loginId: loginId,
                                                                            authToken: authToken))
                    completion("{}")
                } catch {
                    let errorModel = OwnID.CoreSDK.UserErrorModel(message: error.localizedDescription)
                    handleError(bridgeContext: bridgeContext, errorModel: errorModel)
                    
                    completion(handleErrorResult(errorMessage: error.localizedDescription))
                }
            default:
                break
            }
        }
        
        private func convertValue(dict: [String: Any], key: String) -> String? {
            var value: String?
            if let data = dict[key] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    value = String(data: jsonData, encoding: .utf8)
                } catch {
                    let errorModel = OwnID.CoreSDK.UserErrorModel(message: error.localizedDescription)
                    ErrorWrapper(error: .userError(errorModel: errorModel), type: Self.self).log()
                }
            } else {
                value = dict[key] as? String
            }
            return value
        }
        
        private func handleError(bridgeContext: OwnIDWebBridgeContext, errorModel: OwnID.CoreSDK.UserErrorModel) {
            bridgeContext.resultPublisher?.send(WebFlowResult.error(error: OwnID.CoreSDK.Error.userError(errorModel: errorModel)))
            ErrorWrapper(error: .userError(errorModel: errorModel), type: Self.self).log()
        }
        
        private func handleErrorResult(errorMessage: String) -> String {
            let error = JSError(type: String(describing: Self.self),
                                errorMessage: errorMessage,
                                errorCode: "ownIdWebViewBridgeFlowError")
            guard let jsonData = try? JSONEncoder().encode(error),
                  let errorString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                return "{}"
            }
            return errorString
        }
    }
}
