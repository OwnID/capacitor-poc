import XCTest
import Combine
@testable import OwnIDCoreSDK

final class OTPTextFieldViewModelTests: XCTestCase {
    private enum Constants {
        static let codeLenght = 5
    }
    
    var sut: OwnID.UISDK.OneTimePassword.ViewModel!
    var eventService: EventServiceMock!
    
    override func setUp() {
        super.setUp()
        
        let state = OwnID.UISDK.OneTimePassword.ViewState(type: .login)
        let store = Store<OwnID.UISDK.OneTimePassword.ViewState, OwnID.UISDK.OneTimePassword.Action>(initialValue: state,
                          reducer: { OwnID.UISDK.OneTimePassword.viewModelReducer(state: &$0, action: $1) })
        eventService = EventServiceMock()
        sut = OwnID.UISDK.OneTimePassword.ViewModel(codeLength: Constants.codeLenght, store: store, context: nil, operationType: .oneTimePasswordSignIn, loginId: "", eventService: eventService)
    }
    
    override func tearDown() {
        super.tearDown()
        
        sut = nil
        eventService = nil
    }
    
    func testCharacterSaveAndFocusMoveForward() {
        sut.processTextChange(for: 0, binding: .constant("1"))
        XCTAssertEqual(sut.combineCode(), "1")
        XCTAssertEqual(sut.currentFocusedFieldIndex, 1)
        
        sut.processTextChange(for: 1, binding: .constant("2"))
        XCTAssertEqual(sut.combineCode(), "12")
        XCTAssertEqual(sut.currentFocusedFieldIndex, 2)
        
        sut.processTextChange(for: 2, binding: .constant("3"))
        XCTAssertEqual(sut.combineCode(), "123")
        XCTAssertEqual(sut.currentFocusedFieldIndex, 3)
        
        sut.processTextChange(for: 3, binding: .constant("4"))
        XCTAssertEqual(sut.combineCode(), "1234")
        XCTAssertEqual(sut.currentFocusedFieldIndex, 4)
        
        sut.processTextChange(for: 4, binding: .constant("5"))
        XCTAssertEqual(sut.combineCode(), "12345")
        XCTAssertEqual(sut.currentFocusedFieldIndex, 4)
        
        sut.processTextChange(for: 2, binding: .constant("2"))
        XCTAssertEqual(sut.combineCode().count, Constants.codeLenght)
        XCTAssertEqual(sut.combineCode(), "12345")
    }
    
//    func testFocusOnLeftField() {
//        if #available(iOS 16, *) {
//            sut.processTextChange(for: 0, binding: .constant("1"))
//            XCTAssertEqual(sut.combineCode(), "1")
//            XCTAssertEqual(sut.currentFocusedFieldIndex, 1)
//            
//            sut.processTextChange(for: 1, binding: .constant(""))
//            XCTAssertEqual(sut.currentFocusedFieldIndex, 0)
//            
//            sut.processTextChange(for: 0, binding: .constant(""))
//            XCTAssertEqual(sut.combineCode(), "")
//            XCTAssertEqual(sut.currentFocusedFieldIndex, 0)
//        }
//    }
    
    func testCharacterIsNotNumber() {
        sut.processTextChange(for: 0, binding: .constant("aaaa"))
        XCTAssertEqual(sut.combineCode(), "")
    }
    
    func testPasteCode() {
        let result = "12345"
        sut.processTextChange(for: 0, binding: .constant(result))
        XCTAssertEqual(sut.combineCode(), result)
        
        XCTAssertEqual(eventService.metric?.action, OwnID.CoreSDK.AnalyticActionType.userPastedCode.actionValue)
    }
    
    func testResetCode() {
        sut.processTextChange(for: 0, binding: .constant("1"))
        sut.processTextChange(for: 1, binding: .constant("2"))
        XCTAssertEqual(sut.combineCode(), "12")
        
        sut.resetCode()
        XCTAssertEqual(sut.combineCode(), "")
        
        sut.processTextChange(for: 4, binding: .constant("5"))
        XCTAssertEqual(sut.currentFocusedFieldIndex, 0)
    }
    
    func testDisableCodes() {
        sut.disableCodes()
        XCTAssertTrue(sut.isDisabled)
    }
}
