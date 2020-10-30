//
//  SLClientTests+loginTests.swift
//  SimpleLoginTests
//
//  Created by Thanh-Nhon Nguyen on 29/10/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
@testable import SimpleLogin
import XCTest

class SLClientLoginTests: XCTestCase {
    func whenLoginWith(engine: NetworkEngine) throws -> (userLogin: UserLogin?, error: SLError?) {
        var storedUserLogin: UserLogin?
        var storedError: SLError?

        let client = try SLClient(engine: engine)
        client.login(email: "", password: "", deviceName: "") { result in
            switch result {
            case .success(let userLogin): storedUserLogin = userLogin
            case .failure(let error): storedError = error
            }
        }

        return (storedUserLogin, storedError)
    }

    func testLoginSuccessWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "POST_login_Response"))
        let engine = NetworkEngineMock(data: data, statusCode: 200)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNotNil(result.userLogin)
        XCTAssertNil(result.error)
    }

    func testLoginFailureWithStatusCode200() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "POST_login_MissingValueResponse"))
        let engine = NetworkEngineMock(data: data, statusCode: 200)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNotNil(result.error)
        XCTAssertNil(result.userLogin)
    }

    func testLoginFailureWithStatusCode400() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "POST_login_EmailOrPasswordIncorrect"))
        let engine = NetworkEngineMock(data: data, statusCode: 400)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, SLError.emailOrPasswordIncorrect)
    }

    func testLoginFailureWithStatusCode500() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "DummyData"))
        let engine = NetworkEngineMock(data: data, statusCode: 500)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, SLError.internalServerError)
    }

    func testLoginFailureWithStatusCode502() throws {
        // given
        let data = try XCTUnwrap(Data.fromJson(fileName: "DummyData"))
        let engine = NetworkEngineMock(data: data, statusCode: 502)

        // when
        let result = try whenLoginWith(engine: engine)

        // then
        XCTAssertNil(result.userLogin)
        XCTAssertEqual(result.error, SLError.badGateway)
    }
}
