//
//  AdAttributionFetcherTests.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import XCTest

@testable import DuckDuckGo
import PersistenceTestingUtils
import NetworkingTestingUtils

final class AdAttributionFetcherTests: XCTestCase {

    private let mockSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)

        return session
    }()

    override func setUpWithError() throws {
        MockURLProtocol.requestHandler = MockURLProtocol.defaultHandler
    }

    override func tearDownWithError() throws {
        MockURLProtocol.requestHandler = nil
    }

    func testMakesRequestWithToken() async throws {
        let testToken = "foo"
        let sut = DefaultAdAttributionFetcher(tokenGetter: { testToken }, urlSession: mockSession, retryInterval: .leastNonzeroMagnitude)

        _ = await sut.fetch()

        let requestStream = try XCTUnwrap(MockURLProtocol.lastRequest?.httpBodyStream)
        let requestBody = try Data(reading: requestStream)

        XCTAssertEqual(String(data: requestBody, encoding: .utf8), testToken)
    }

    func testRetriesRequest() async throws {
        let testToken = "foo"
        let sut = DefaultAdAttributionFetcher(tokenGetter: { testToken }, urlSession: mockSession, retryInterval: .leastNonzeroMagnitude)
        let retryExpectation = XCTestExpectation()
        retryExpectation.expectedFulfillmentCount = 3
        retryExpectation.assertForOverFulfill = true

        MockURLProtocol.requestHandler = { request in
            retryExpectation.fulfill()
            let handler = MockURLProtocol.handler(with: 404)
            return try handler(request)
        }

        _ = await sut.fetch()

        let requestStream = try XCTUnwrap(MockURLProtocol.lastRequest?.httpBodyStream)
        let requestBody = try Data(reading: requestStream)

        XCTAssertEqual(String(data: requestBody, encoding: .utf8), testToken)

        await fulfillment(of: [retryExpectation])
    }

    func testRefreshesTokenOnRetry() async throws {
        let retryExpectation = XCTestExpectation()
        retryExpectation.expectedFulfillmentCount = 3
        retryExpectation.assertForOverFulfill = true

        let refreshExpectation = XCTestExpectation()

        let testToken = "foo"
        let sut = DefaultAdAttributionFetcher(tokenGetter: {
            refreshExpectation.fulfill()
            return testToken
        }, urlSession: mockSession, retryInterval: .leastNonzeroMagnitude)

        MockURLProtocol.requestHandler = { request in
            retryExpectation.fulfill()
            let handler = MockURLProtocol.handler(with: 400)
            return try handler(request)
        }

        _ = await sut.fetch()

        let requestStream = try XCTUnwrap(MockURLProtocol.lastRequest?.httpBodyStream)
        let requestBody = try Data(reading: requestStream)

        XCTAssertEqual(String(data: requestBody, encoding: .utf8), testToken)

        await fulfillment(of: [retryExpectation])
    }

    func testDoesNotRetry_WhenUnrecoverable() async throws {
        let testToken = "foo"
        let sut = DefaultAdAttributionFetcher(tokenGetter: { testToken }, urlSession: mockSession, retryInterval: .leastNonzeroMagnitude)
        let noRetryExpectation = XCTestExpectation()
        noRetryExpectation.expectedFulfillmentCount = 1
        noRetryExpectation.assertForOverFulfill = true

        MockURLProtocol.requestHandler = { request in
            noRetryExpectation.fulfill()
            let handler = MockURLProtocol.handler(with: 500)
            return try handler(request)
        }

        _ = await sut.fetch()

        let requestStream = try XCTUnwrap(MockURLProtocol.lastRequest?.httpBodyStream)
        let requestBody = try Data(reading: requestStream)

        XCTAssertEqual(String(data: requestBody, encoding: .utf8), testToken)

        await fulfillment(of: [noRetryExpectation])
    }

    func testRespectsRetryInterval() async throws {
        let testToken = "foo"
        let sut = DefaultAdAttributionFetcher(tokenGetter: { testToken }, urlSession: mockSession, retryInterval: .milliseconds(30))

        MockURLProtocol.requestHandler = { request in
            let handler = MockURLProtocol.handler(with: 404)
            return try handler(request)
        }

        let startTime = Date()
        _ = await sut.fetch()

        XCTAssertGreaterThanOrEqual(Date().timeIntervalSince(startTime), .milliseconds(90))
    }
}

private extension MockURLProtocol {
    typealias RequestHandler = (URLRequest) throws -> (HTTPURLResponse, Data?)

    static func handler(with statusCode: Int, data: Data? = nil) -> RequestHandler {
        return { request in
            (HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!, data)
        }
    }

    static let defaultHandler = handler(with: 300)
}

private extension Data {
    init(reading input: InputStream, size: Int = 1024) throws {
        self.init()
        input.open()
        defer {
            input.close()
        }

        let bufferSize = size
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer {
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Stream error occured
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}
