import Foundation

public extension OwnID.CoreSDK {
    class LogItem: LogMetricProtocol {
        public var context: String?
        public var component = LoggerConstants.component
        var requestPath = ""
        let level: LogLevel
        let codeInitiator: String?
        var message: String
        var errorMessage: String?
        public var metadata: Metadata?
        public var userAgent = UserAgentManager.shared.SDKUserAgent
        public var version = UserAgentManager.shared.version
        public var sourceTimestamp = String(Int((Date().timeIntervalSince1970 * 1000.0).rounded()))
        
        init(context: String = "",
             level: LogLevel,
             codeInitiator: String? = nil,
             message: String,
             errorMessage: String? = nil,
             metadata: Metadata? = nil) {
            self.context = context
            self.level = level
            self.codeInitiator = codeInitiator
            self.message = message
            self.errorMessage = errorMessage
            self.metadata = metadata
        }
    }
}

extension OwnID.CoreSDK.LogItem: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        context: \(context ?? "")
        message: \(message)
        level: \(level.priority)
        codeInitiator: \(codeInitiator ?? "")
        userAgent: \(userAgent)
        version: \(version)
        metadata: \(metadata?.debugDescription ?? "")
    """
    }
}
