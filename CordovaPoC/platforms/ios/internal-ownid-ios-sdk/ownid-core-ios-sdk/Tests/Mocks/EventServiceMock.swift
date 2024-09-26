@testable import OwnIDCoreSDK

final class EventServiceMock: EventProtocol {
    var metric: OwnID.CoreSDK.Metric? = nil
    
    func sendMetric(_ metric: OwnID.CoreSDK.Metric) {
        self.metric = metric
    }
}
