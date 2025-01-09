//
//  AIChatPayloadHandlerTests.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

final class AIChatPayloadHandlerTests: XCTestCase {

    var payloadHandler: AIChatPayloadHandler!
    
    override func setUp() {
        super.setUp()
        payloadHandler = AIChatPayloadHandler()
    }
    
    override func tearDown() {
        payloadHandler = nil
        super.tearDown()
    }
    
    func testSetPayload() {
        let testPayload: AIChatPayload = ["key": "value"]
        payloadHandler.setPayload(testPayload)
        
        let consumedPayload = payloadHandler.consumePayload()
        XCTAssertEqual(consumedPayload?["key"] as? String, "value", "The payload should be set correctly.")
    }
    
    func testConsumePayload() {
        let testPayload: AIChatPayload = ["key": "value"]
        payloadHandler.setPayload(testPayload)
        
        let consumedPayload = payloadHandler.consumePayload()
        XCTAssertEqual(consumedPayload?["key"] as? String, "value", "The payload should be consumed correctly.")
        
        let secondConsume = payloadHandler.consumePayload()
        XCTAssertNil(secondConsume, "The payload should be nil after being consumed.")
    }
    
    func testReset() {
        let testPayload: AIChatPayload = ["key": "value"]
        payloadHandler.setPayload(testPayload)
        
        payloadHandler.reset()
        
        let consumedPayload = payloadHandler.consumePayload()
        XCTAssertNil(consumedPayload, "The payload should be nil after reset.")
    }
}
