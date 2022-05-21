//
//  stateraUITestsLaunchTests.swift
//  stateraUITests
//
//  Created by Andrii Denysenko on 2022-05-10.
//

import XCTest

class stateraUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        sleep(10)
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("user@example.com")
        let passwordTextField = app.textFields["Password"]
        passwordTextField.tap()
        passwordTextField.typeText("Qweqwe1!")
        app.buttons["Sign In"].tap()
        sleep(10)
                
        snapshot("GroupsList")
        
        app.staticTexts["Home\n2"].tap()
        sleep(10)
        snapshot("GroupPage")
        
        app.staticTexts["Expenses\nTab 2 of 2"].tap()
        sleep(10)
        snapshot("ExpensesList")
        
        // tap expense
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 0).children(matching: .other).element.tap()
        sleep(10)
        snapshot("ExpensePage")
        
        let backButton = app.buttons["Back"]
        backButton.tap()
        app.staticTexts["Home\nTab 1 of 2"].tap()
        
        // TODO: include payments
//        app.buttons["Admin\n$-6.50"].tap()
//        sleep(2)
//        snapshot("PaymentsList")
//        backButton.tap()
        
        backButton.tap()
        // logout
//        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 1).children(matching: .button).element.tap()
//
//        app.windows.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching:
//            .other).element(boundBy: 1).children(matching:
//            .other).element(boundBy: 1).children(matching:
//            .other).element(boundBy: 1).children(matching:
//            .other).element(boundBy: 1).children(matching:
//            .button).element.tap()
//
//        sleep(2)
    }
}
