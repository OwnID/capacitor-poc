import XCTest
import Combine
@testable import OwnIDCoreSDK

final class IdCollectViewModelTests: XCTestCase {
    var state: OwnID.UISDK.IdCollect.ViewState!
    var store: Store<OwnID.UISDK.IdCollect.ViewState, OwnID.UISDK.IdCollect.Action>!
    var sut: OwnID.UISDK.IdCollect.ViewModel!
    
    override func setUp() {
        super.setUp()
        
        state = OwnID.UISDK.IdCollect.ViewState()
        store = Store<OwnID.UISDK.IdCollect.ViewState, OwnID.UISDK.IdCollect.Action>(initialValue: state, reducer: { OwnID.UISDK.IdCollect.viewModelReducer(state: &$0, action: $1) })
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "",
                                              loginIdSettings: .init(type: .email, regex: "^(?=(.{1,64}@.{1,255}))([\\w!#$%&\'*+/=?^`{|}~-]{1,64}(\\.[\\w!#$%&\'*+/=?^`{|}~-]*)*)@((\\[(25[0-5]|2[0-4]\\d|[01]?\\d{1,2})(\\.(25[0-5]|2[0-4]\\d|[01]?\\d{1,2})){3}])|([\\dA-Za-z-]{1,63}(\\.[\\dA-Za-z-]{2,63})+))$"),
                                              isPasskeysSupported: true,
                                              phoneCodes: [])
    }
    
    override func tearDown() {
        super.tearDown()
        
        state = nil
        store = nil
        sut = nil
    }
    
    func testTitleKeyPasskeysSupported() {
        let key = OwnID.CoreSDK.TranslationsSDK.TranslationKey.idCollectTitle(type: sut.loginIdType.rawValue)
        XCTAssertEqual(sut.titleKey.value, key.value)
    }
    
    func testTitleKeyPasskeysNotSupported() {
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "",
                                              loginIdSettings: .init(type: .email, regex: ""),
                                              isPasskeysSupported: false,
                                              phoneCodes: [])
        let key = OwnID.CoreSDK.TranslationsSDK.TranslationKey.idCollectNoBiometricsTitle(type: sut.loginIdType.rawValue)
        XCTAssertEqual(sut.titleKey.value, key.value)
    }
    
    func testMessageKeyPasskeysSupported() {
        let key = OwnID.CoreSDK.TranslationsSDK.TranslationKey.idCollectMessage(type: sut.loginIdType.rawValue)
        XCTAssertEqual(sut.messageKey.value, key.value)
    }
    
    func testMessageKeyPasskeysNotSupported() {
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "",
                                              loginIdSettings: .init(type: .email, regex: ""),
                                              isPasskeysSupported: false,
                                              phoneCodes: [])
        let key = OwnID.CoreSDK.TranslationsSDK.TranslationKey.idCollectNoBiometricsMessage(type: sut.loginIdType.rawValue)
        XCTAssertEqual(sut.messageKey.value, key.value)
    }
    
    func testDefaultPhoneCode() {
        let phoneCodesJson = [["code": "UA",
                               "dialCode": "+",
                               "emoji": "",
                               "name": "Ukraine"],
                              ["code": "US",
                               "dialCode": "+",
                               "emoji": "",
                               "name": "USA"]]
        
        do {
            let json = try JSONSerialization.data(withJSONObject: phoneCodesJson)
            let decoder = JSONDecoder()
            let phoneCodes = try decoder.decode([OwnID.CoreSDK.PhoneCode].self, from: json)
            
            sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                                  loginId: "",
                                                  loginIdSettings: .init(type: .email, regex: ""),
                                                  isPasskeysSupported: false,
                                                  phoneCodes: phoneCodes)
            XCTAssertEqual(sut.defaultPhoneCode, phoneCodes.last)
            
        } catch {
            print(error)
        }
    }
    
    func testDefaultPhoneCodeFallback() {
        let phoneCodesJson = [["code": "UA",
                               "dialCode": "+",
                               "emoji": "",
                               "name": "Ukraine"],
                              ["code": "GB",
                               "dialCode": "+",
                               "emoji": "",
                               "name": "Great Britain"]]
        
        do {
            let json = try JSONSerialization.data(withJSONObject: phoneCodesJson)
            let decoder = JSONDecoder()
            let phoneCodes = try decoder.decode([OwnID.CoreSDK.PhoneCode].self, from: json)
            
            sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                                  loginId: "",
                                                  loginIdSettings: .init(type: .email, regex: ""),
                                                  isPasskeysSupported: false,
                                                  phoneCodes: phoneCodes)
            XCTAssertEqual(sut.defaultPhoneCode, phoneCodes.first)
            
        } catch {
            print(error)
        }
    }
    
    func testUpdateLoginIdPublisher() {
        let loginIdPublisher = PassthroughSubject<String, Never>()
        sut.updateLoginIdPublisher(loginIdPublisher.eraseToAnyPublisher())
        
        let loginId = "user"
        loginIdPublisher.send(loginId)
        
        XCTAssertEqual(sut.loginId, loginId)
    }
    
    func testUpdatePhoneDialCodePublisher() {
        let phoneDialCodePublisher = PassthroughSubject<String, Never>()
        sut.updatePhoneDialCodePublisher(phoneDialCodePublisher.eraseToAnyPublisher())
        
        let phoneDialCode = "+1"
        phoneDialCodePublisher.send(phoneDialCode)
        
        XCTAssertEqual(sut.phoneDialCode, phoneDialCode)
    }
    
    func testPostLoginIdWithEmptyEmail() {
        sut.postLoginId()
        XCTAssertTrue(sut.isError)
    }
    
    func testPostLoginIdWithEmptyPhone() {
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "",
                                              loginIdSettings: .init(type: .phoneNumber, regex: ""),
                                              isPasskeysSupported: true,
                                              phoneCodes: [])
        sut.postLoginId()
        XCTAssertTrue(sut.isError)
    }
    
    func testPostLoginIdWithNotValidEmail() {
        let loginIdPublisher = PassthroughSubject<String, Never>()
        sut.updateLoginIdPublisher(loginIdPublisher.eraseToAnyPublisher())
        
        let loginId = "user"
        loginIdPublisher.send(loginId)
        
        sut.postLoginId()
        XCTAssertTrue(sut.isError)
    }
    
    func testPostLoginIdWithNotValidPhone() {
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "dfdfdf",
                                              loginIdSettings: .init(type: .phoneNumber, regex: "^\\+[1-9]\\d{1,14}$"),
                                              isPasskeysSupported: true,
                                              phoneCodes: [])
        sut.postLoginId()
        XCTAssertTrue(sut.isError)
    }
    
    func testPostLoginIdWithEmail() {
        let loginIdPublisher = PassthroughSubject<String, Never>()
        sut.updateLoginIdPublisher(loginIdPublisher.eraseToAnyPublisher())
        
        let loginId = "email@ownidtest.com"
        loginIdPublisher.send(loginId)
        
        sut.postLoginId()
        XCTAssertFalse(sut.isError)
    }
    
    func testPostLoginIdWithPhone() {
        sut = OwnID.UISDK.IdCollect.ViewModel(store: store,
                                              loginId: "3434343433",
                                              loginIdSettings: .init(type: .phoneNumber, regex: "^\\+[1-9]\\d{1,14}$"),
                                              isPasskeysSupported: true,
                                              phoneCodes: [])
        
        let phoneDialCodePublisher = PassthroughSubject<String, Never>()
        sut.updatePhoneDialCodePublisher(phoneDialCodePublisher.eraseToAnyPublisher())
        
        let phoneDialCode = "+1"
        phoneDialCodePublisher.send(phoneDialCode)
        
        sut.postLoginId()
        XCTAssertFalse(sut.isError)
    }
}
