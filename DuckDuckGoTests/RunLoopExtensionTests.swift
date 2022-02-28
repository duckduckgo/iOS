//
//  RunLoopExtensionTests.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation
import XCTest
@testable import Core

class RunLoopExtensionTests: XCTestCase {

    func testWhenConditionResolvedThenNoWaitIsPerformed() {
        let condition = RunLoop.ResumeCondition()
        condition.resolve()

        let e = expectation(description: "should execute after wait")
        var isExecuted = false
        RunLoop.current.perform {
            isExecuted = true
            e.fulfill()
        }

        RunLoop.current.run(until: condition)
        XCTAssertFalse(isExecuted)

        waitForExpectations(timeout: 10)
    }

    func testWhenConditionIsResolvedThenWaitIsFinished() {
        let condition = RunLoop.ResumeCondition()

        let e = expectation(description: "should execute")
        RunLoop.current.perform {
            condition.resolve()
            e.fulfill()
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

    func testWhenDispatchGroupIsEmptyThenNoWaitIsPerformed() {
        let dispatchGroup = DispatchGroup()
        let condition = RunLoop.ResumeCondition(dispatchGroup: dispatchGroup)

        let e = expectation(description: "should execute")
        RunLoop.current.perform {
            e.fulfill()
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

    func testWhenDispatchGroupIsCompleteThenWaitIsFinished() {
        let dispatchGroup = DispatchGroup()
        let condition = RunLoop.ResumeCondition(dispatchGroup: dispatchGroup)

        let e = expectation(description: "should execute")
        RunLoop.current.perform {
            e.fulfill()
        }

        for _ in 0..<3 {
            dispatchGroup.enter()
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
                dispatchGroup.leave()
            }
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

    func testWhenNestedWaitIsCalledThenWaitIsPerformed() {
        let condition = RunLoop.ResumeCondition()

        let e = expectation(description: "should execute")
        RunLoop.current.perform {
            RunLoop.current.perform {
                condition.resolve()
                e.fulfill()
            }
            RunLoop.current.run(until: condition)
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

    func testWhenResolveFromBackgroundThreadThenWaitIsFinished() {
        let condition = RunLoop.ResumeCondition()
        
        let e = expectation(description: "should execute")

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            condition.resolve()
            e.fulfill()
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

    func testWhenWaitingInBackgroundThreadThenWaitIsFinishedWhenResolved() {
        let condition = RunLoop.ResumeCondition()

        let e = expectation(description: "should execute")
        DispatchQueue.global().async {
            RunLoop.current.run(until: condition)
            e.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
            condition.resolve()
        }

        RunLoop.current.run(until: condition)
        waitForExpectations(timeout: 10)
    }

}
