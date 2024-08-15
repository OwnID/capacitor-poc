import XCTest
import Combine
@testable import OwnIDCoreSDK

final class EmptyContainer {
    
}

final class RegistrationPerformerMock: RegistrationPerformer {
    var isError = false
    
    func register(configuration: OwnID.FlowsSDK.RegistrationConfiguration, parameters: RegisterParameters) -> OwnID.RegistrationResultPublisher {
        if isError {
            let errorModel = OwnID.CoreSDK.UserErrorModel(message: "")
            let error = OwnID.CoreSDK.Error.userError(errorModel: errorModel)
            return Fail<OwnID.RegisterResult, OwnID.CoreSDK.Error>(error: error)
                .eraseToAnyPublisher()
        } else {
            return Just(OwnID.RegisterResult(operationResult: VoidOperationResult())).setFailureType(to: OwnID.CoreSDK.Error.self)
                .eraseToAnyPublisher()
        }
    }
}

final class LoginPerformerMock: LoginPerformer {
    var isError = false
    
    func login(payload: OwnID.CoreSDK.Payload, loginId: String) -> OwnID.LoginResultPublisher {
        if isError {
            let errorModel = OwnID.CoreSDK.UserErrorModel(message: "")
            let error = OwnID.CoreSDK.Error.userError(errorModel: errorModel)
            return Fail<OwnID.LoginResult, OwnID.CoreSDK.Error>(error: error)
                .eraseToAnyPublisher()
        } else {
            return Just(OwnID.LoginResult(operationResult: VoidOperationResult())).setFailureType(to: OwnID.CoreSDK.Error.self)
                .eraseToAnyPublisher()
        }
    }
}

final class RegisterViewModelTests: XCTestCase {
    var sut: OwnID.FlowsSDK.RegisterView.ViewModel!
    var eventService: EventServiceMock!
    let loginIdPublisher = PassthroughSubject<String, Never>()
    var bag = Set<AnyCancellable>()
    
    let savedLoginIdValue = OwnID.CoreSDK.DefaultsLoginIdSaver.loginId()
    
    override func setUp() {
        super.setUp()
        
        OwnID.CoreSDK.shared.configureForTests()
        
        eventService = EventServiceMock()
        sut = OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: RegistrationPerformerMock(),
                                                    loginPerformer: LoginPerformerMock(),
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
    
    func testShouldShowTooltipDefaultLogic() {
        let exp = expectation(description: #function)
        
        loginIdPublisher
            .debounce(for: .seconds(0.6), scheduler: DispatchQueue.main)
            .sink { _ in
                exp.fulfill()
                
                XCTAssertFalse(self.sut.shouldShowTooltip)
        }
        .store(in: &bag)
        
        loginIdPublisher.send("")
        
        waitForExpectations(timeout: 0.6)
    }
    
    func testSuccessRegistration() {
        let loginId = "111111@kfef.ee"
        let exp = expectation(description: #function)
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()

        XCTAssertEqual(sut.state.buttonState, .enabled)
        XCTAssertFalse(sut.state.isLoading)
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success(let event):
                switch event {
                case .loading, .resetTapped, .readyToRegister:
                    break
                case .userRegisteredAndLoggedIn:
                    exp.fulfill()
                    
                    XCTAssertEqual(self.sut.state.buttonState, .activated)
                    XCTAssertFalse(self.sut.state.isLoading)
                }

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &bag)
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .registrationInfo, authType: .none, requestLanguage: "")))
        sleep(1)
        sut.register()
        waitForExpectations(timeout: 0.1)
    }
    
    func testFailureRegistration() {
        let registrationPerformer = RegistrationPerformerMock()
        registrationPerformer.isError = true
        sut = OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: registrationPerformer,
                                                    loginPerformer: LoginPerformerMock(),
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
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .registrationInfo, authType: .none, requestLanguage: "")))
        sleep(1)
        sut.register()
        waitForExpectations(timeout: 0.1)
    }
    
    func testErrorPayloadMissing() {
        let loginId = "111111@kfef.ee"
        let exp = expectation(description: #function)
        let eventPublisher = PassthroughSubject<Void, Never>()
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success:
                XCTFail()
                
            case .failure(let error):
                switch error {
                case .userError(let errorModel):
                    exp.fulfill()
                    
                    XCTAssertEqual(errorModel.code, .unknown)
                default:
                    break
                }
            }
        }
        .store(in: &bag)
        sut.subscribe(to: eventPublisher.eraseToAnyPublisher())
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        loginIdPublisher.send(loginId)
        eventPublisher.send(())
        sleep(1)
        sut.register()
        waitForExpectations(timeout: 0.1)
    }
    
    func testResetToInitialState() {
        sut.skipPasswordTapped(loginId: "")
        XCTAssertTrue(self.sut.state.isLoading)
        
        sut.skipPasswordTapped(loginId: "")
        XCTAssertEqual(sut.state, .initial)
    }
    
    func testUndoState() {
        let loginId = "111111@kfef.ee"
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()

        XCTAssertEqual(sut.state.buttonState, .enabled)
        XCTAssertFalse(self.sut.state.isLoading)
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success(let event):
                switch event {
                case .readyToRegister:
                    self.sut.skipPasswordTapped(loginId: loginId)
                    XCTAssertEqual(self.eventService.metric?.action, OwnID.CoreSDK.AnalyticActionType.undo.actionValue)
                    XCTAssertEqual(self.sut.state, .initial)
                default:
                    break
                }

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &bag)
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .registrationInfo, authType: .none, requestLanguage: "")))
    }
    
    func testSuccessLogin() {
        let loginId = "111111@kfef.ee"
        let exp = expectation(description: #function)
        let coreVMPublisher = PassthroughSubject<OwnID.CoreSDK.CoreViewModel.Event, OwnID.CoreSDK.Error>()
        
        sut.integrationEventPublisher.sink { result in
            switch result {
            case .success(let event):
                switch event {
                case .loading, .resetTapped, .readyToRegister:
                    break
                case .userRegisteredAndLoggedIn:
                    exp.fulfill()
                }

            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        .store(in: &bag)
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .session, authType: .none, requestLanguage: "")))
        waitForExpectations(timeout: 0.1)
    }
    
    func testFailureLogin() {
        let loginPerformer = LoginPerformerMock()
        loginPerformer.isError = true
        sut = OwnID.FlowsSDK.RegisterView.ViewModel(registrationPerformer: RegistrationPerformerMock(),
                                                    loginPerformer: loginPerformer,
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
        
        sut.subscribe(to: coreVMPublisher.eraseToAnyPublisher(), persistingLoginId: loginId)
        coreVMPublisher.send(.success(OwnID.CoreSDK.Payload(data: "", metadata: EmptyContainer(), context: "", loginId: loginId, responseType: .session, authType: .none, requestLanguage: "")))
        waitForExpectations(timeout: 0.1)
    }
}
