//
//  FirstTest.swift
//  SimpleLoginUITests
//
//  Created by Ilya Smotrov on 23.03.2023.
//

import XCTest

final class FirstTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func scrollToElement(element: XCUIElement, app: XCUIApplication) {
        while !(element.isHittable) {
            app.swipeUp()
        }
        XCTAssertTrue(element.isHittable)
    }
    
    func confirmWelcomeScreen(app: XCUIApplication) {
        let gotItButton = app.buttons["Got it 👍"];
        scrollToElement(element: gotItButton, app: app)
        gotItButton.tap()
    }
    
    func testFirst() throws {
        // UI tests must launch the application that they test.
        
        let app = XCUIApplication()
        app.launch()
        
        
        /*
         1. Ввести email alexsimplestar@gmail.com
         2. Ввести пароль 1234Qwer!
         3. Нажать кнопку SignIn
        */
        let emailField = app.textFields["Email"]
        emailField.tap()
                                        
        let clearEmailFieldButton = app.buttons["Закрыть"]
        clearEmailFieldButton.tap()
        emailField.typeText("alexsimplestar@gmail.com")

        let passwordField = app.secureTextFields["Password"]
        passwordField.tap()
        passwordField.typeText("1234Qwer!")
        
        let loginButton = app.buttons["Log in"]
        loginButton.tap()
    
        confirmWelcomeScreen(app: app)
        
        /*
         4. Проверка Aliases страница открыта
         5. Проверка карточка alias отображается
         6. Проверка вкладка All выбрана
         7. Проверка вкладка Active НЕ выбрана
         8. Проверка вкладка Inactive НЕ выбрана
         */
        
        let navBar = app.navigationBars["_TtGC7SwiftUI19UIHosting"];
        let alias = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        
        
        XCTAssertTrue(alias.exists, "Алиас не отображатеся во вкладке All")

        XCTAssertTrue(navBar.buttons["All"].isSelected)
        XCTAssertFalse(navBar.buttons["Active"].isSelected)
        XCTAssertFalse(navBar.buttons["Inactive"].isSelected)

        /*
         9. Нажать на кладку Active
         10. Проверка вкладка All НЕ выбрана
         11. Проверка вкладка Aсtive выбрана
         12. Проверка вкладка  Inactive НЕ выбрана
         13. Проверка карточка alias отображается
         */

        navBar.buttons["Active"].tap()

        XCTAssertFalse(navBar.buttons["All"].isSelected)
        XCTAssertTrue(navBar.buttons["Active"].isSelected)
        XCTAssertFalse(navBar.buttons["Inactive"].isSelected)

        XCTAssertTrue(alias.exists, "Алиас не отображатеся во вкладке Active")

        /*
         14. Нажать на кладку Inactive
         15. Проверка вкладка All НЕ выбрана
         16. Проверка вкладка Active НЕ выбрана
         17. Проверка вкладка  Inactive выбрана
         18. Проверка карточка alias не отображается

         */

        navBar.buttons["Inactive"].tap()

        XCTAssertFalse(navBar.buttons["All"].isSelected)
        XCTAssertFalse(navBar.buttons["Active"].isSelected)
        XCTAssertTrue(navBar.buttons["Inactive"].isSelected)

        XCTAssertFalse(alias.exists, "Алиас отображатеся во вкладке Inactive")

        /*
         19. Нажать на кладку All
         20. Проверка вкладка All выбрана
         21. Проверка вкладка Active НЕ выбрана
         22. Проверка вкладка Inactive НЕ выбрана
         23. Проверка переключатель на карточке alias включен
         24. Нажать на переключатель на карточке alias
         25. Проверка переключатель на карточке alias выключен

         */

        navBar.buttons["All"].tap()

        XCTAssertTrue(navBar.buttons["All"].isSelected)
        XCTAssertFalse(navBar.buttons["Active"].isSelected)
        XCTAssertFalse(navBar.buttons["Inactive"].isSelected)

        XCTAssertTrue(alias.buttons["Active"].images["Выбрано"].exists, "Переключатель Active не выбран")

        alias.buttons["Active"].tap()
        XCTAssertFalse(alias.buttons["Active"].images["Выбрано"].exists, "Переключатель Active выбран")

        /*
         26. Нажать на кладку Active
         27. Проверка карточка alias не отображается
         28. Нажать на кладку Inactive
         29. Проверка карточка alias отображается
         30. Нажать на кладку All
         31. Проверка карточка alias отображается

         */

        navBar.buttons["Active"].tap()
        XCTAssertFalse(alias.exists, "Алиас отображается на вкладке Active")
        
        navBar.buttons["Inactive"].tap()
        XCTAssertTrue(alias.exists, "Алиас не отображается на вкладке Inactive")
        
        navBar.buttons["All"].tap()
        XCTAssertTrue(alias.exists, "Алиас не отображается на вкладке All")


        /*

         32. Нажать на переключатель на карточке alias
         33. Проверка переключатель на карточке alias включен
         34. Нажать на кладку Active
         35. Проверка карточка alias отображается
         36. Нажать на кладку Inactive
         37. Проверка карточка alias не отображается
         38. Нажать на кладку All
         39. Проверка карточка alias отображается
         */


        alias.buttons["Active"].tap()
        XCTAssertTrue(alias.buttons["Active"].images["Выбрано"].exists)

        navBar.buttons["Active"].tap()
        XCTAssertTrue(alias.exists, "Алиас не отображается во вкладке Active")

        navBar.buttons["Inactive"].tap()
        XCTAssertFalse(alias.exists, "Алиас отображается во вкладке Inactive")

        navBar.buttons["All"].tap()
        XCTAssertTrue(alias.exists, "Алиас не отображается во вкладке All")


        /*
         40. Перейти на страницу аккаунта
         41. Проверка страница аккаунта открыта
         42. Нажать на кнопку upgrade
         43. Проверка страница  upgrade открыта
         44. Нажать кнопку назад
         45. Проверка страница аккаунта открыта
         */
        
        app.staticTexts["My account"].tap()
        XCTAssertTrue(app.navigationBars["My Account"].waitForExistence(timeout: 30))
        
        let upgradeButton = app.navigationBars["My Account"].buttons["Upgrade"]
        XCTAssertTrue(upgradeButton.isHittable)
        upgradeButton.tap()
        
        XCTAssertTrue(app
            .navigationBars["Upgrade for more features"]
            .staticTexts["Upgrade for more features"]
            .exists
        )
        
        app.buttons["My Account"].tap()
        XCTAssertTrue(app.navigationBars["My Account"].waitForExistence(timeout: 30))
        

        /*
         46. Перейти на страницу Aliases
         47. Проверка страница Alises открыта
         48. Проверка карточка alias отображается
         49. Выйти из аккаунта
         50. Проверка страница логина открыта*/
        
        app.staticTexts["Aliases"].tap()
        XCTAssertTrue(alias.exists, "Алиас отображается на экране Aliases")
        
        app.staticTexts["My account"].tap()
        XCTAssertTrue(app.navigationBars["My Account"].waitForExistence(timeout: 30))

        let logOutButton = app.buttons["Log out"];
        scrollToElement(element: logOutButton, app: app)
        logOutButton.tap()

        app.alerts.buttons["Yes, log me out"].tap()
        XCTAssertTrue(app.buttons["Log in"].waitForExistence(timeout: 30), "Пользователь разлогинен и видит форму логина")
        sleep(30)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
