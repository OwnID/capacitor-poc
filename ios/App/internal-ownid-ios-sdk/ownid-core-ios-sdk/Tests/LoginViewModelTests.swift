import XCTest
import Combine
@testable import OwnIDCoreSDK

final class LoginViewModelTests: XCTestCase {
    var sut: OwnID.FlowsSDK.LoginView.ViewModel!
    var eventService: EventServiceMock!
    let loginIdPublisher = PassthroughSubject<String, Never>()
    var bag = Set<AnyCancellable>()
    
    let savedLoginIdValue = OwnID.CoreSDK.DefaultsLoginIdSaver.loginId()

    override func setUp() {
        super.setUp()
        
        OwnID.CoreSDK.shared.configureForTests()
        
        eventService = EventServiceMock()
        sut = OwnID.FlowsSDK.LoginView.ViewModel(loginPerformer: LoginPerformerMock(),
                                                 loginIdPublisher: loginIdPublisher.eraseToAnyPublisher(),
                                                 eventService: eventService)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        eventService = nil
        
        if let savedLoginIdValue {
            OwnID.CoreSDK.DefaultsLoginIdSaver.save(loginId: savedLoginIdValue)
        }
    }
    
    func testSuccessLogin() {
        let loginId = "111111@kfef.ee"
        let exp = expectation(description: #function)
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()

        XCTAssertEqual(sut.state.buttonState, .enabled)
        XCTAssertFalse(self.sut.state.isLoading)
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success(let event):
                switch event {
                case .loading:
                    break
                case .loggedIn:
                    exp.fulfill()
                    
                    XCTAssertFalse(self.sut.state.isLoading)
                }

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &bag)
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher())
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .session, authType: .none, requestLanguage: "")))
        waitForExpectations(timeout: 0.1)
    }
    
    func testFailureLogin() {
        let loginPerformer = LoginPerformerMock()
        loginPerformer.isError = true
        sut = OwnID.FlowsSDK.LoginView.ViewModel(loginPerformer: loginPerformer,
                                                 loginIdPublisher: loginIdPublisher.eraseToAnyPublisher(),
                                                 eventService: eventService)
        
        let loginId = "111111@kfef.ee"
        let exp = expectation(description: #function)
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success:
                break

            case .failure:
                exp.fulfill()
            }
        }
        .store(in: &bag)
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher())
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .session, authType: .none, requestLanguage: "")))
        waitForExpectations(timeout: 0.1)
    }
}
