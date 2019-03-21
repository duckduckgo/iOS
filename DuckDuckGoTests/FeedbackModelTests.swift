//
//  FeedbackModelTests.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
@testable import DuckDuckGo

class FeedbackModelTests: XCTestCase {

    struct Constants {
        static let url = "http://example.com"
        static let message = "A message"
    }

    private var feedbackSenderStub = FeedbackSenderStub()
    private var testee: FeedbackModel!

    override func setUp() {
        testee = FeedbackModel(feedbackSender: feedbackSenderStub)
    }

    func testWhenInitThenDefaultValuesAreCorrect() {
        XCTAssertFalse(testee.isBrokenSite)
        XCTAssertNil(testee.url)
        XCTAssertNil(testee.message)
    }

    func testWhenSiteNotBrokenAndHasMessageThenCanSubmit() {
        testee.isBrokenSite = false
        testee.message = Constants.message
        XCTAssertTrue(testee.canSubmit())
    }

    func testWhenSiteNotBrokenAndMessageIsNilThenCanNotSubmit() {
        testee.isBrokenSite = false
        testee.message = nil
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteNotBrokenAndMessageIsEmptyThenCanNotSubmit() {
        testee.isBrokenSite = false
        testee.message = ""
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteNotBrokenAndMessageIsWhitespaceThenCanNotSubmit() {
        testee.isBrokenSite = false
        testee.message = " "
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndHasUrlAndMessageThenCanSubmit() {
        testee.isBrokenSite = true
        testee.url = Constants.url
        testee.message = Constants.message
        XCTAssertTrue(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsNilThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = nil
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsEmptyThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = ""
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsWhitespaceThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = " "
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsNilThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = Constants.url
        testee.message = nil
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsEmptyThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = Constants.url
        testee.message = ""
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsWhitespaceThenCanNotSubmit() {
        testee.isBrokenSite = true
        testee.url = Constants.url
        testee.message = " "
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenGeneralFeedbackSubmittedThenCorrectSubmissionMade() {
        testee.isBrokenSite = false
        testee.message = Constants.message
        testee.submit()

        XCTAssertTrue(feedbackSenderStub.messageSubmitted)
        XCTAssertFalse(feedbackSenderStub.brokenSiteSubmitted)
        XCTAssertNil(feedbackSenderStub.url)
        XCTAssertEqual(Constants.message, feedbackSenderStub.message)
    }

    func testWhenBrokenSiteSubmittedThenCorrectSubmissionMade() {
        testee.isBrokenSite = true
        testee.url = Constants.url
        testee.message = Constants.message
        testee.submit()

        XCTAssertTrue(feedbackSenderStub.brokenSiteSubmitted)
        XCTAssertFalse(feedbackSenderStub.messageSubmitted)
        XCTAssertEqual(Constants.url, feedbackSenderStub.url)
        XCTAssertEqual(Constants.message, feedbackSenderStub.message)
    }

    func testWhenCannotSubmitThenNoSubmissionMade() {
        testee.submit()
        XCTAssertFalse(feedbackSenderStub.brokenSiteSubmitted)
        XCTAssertFalse(feedbackSenderStub.messageSubmitted)
    }

    class FeedbackSenderStub: FeedbackSender {

        var brokenSiteSubmitted = false
        var messageSubmitted = false

        var url: String?
        var message: String?

        func submitBrokenSite(url: String, message: String) {
            brokenSiteSubmitted = true
            self.url = url
            self.message = message
        }

        func submitMessage(message: String) {
            messageSubmitted = true
            self.message = message
        }
        
        func firePositiveSentimentPixel() {
            
        }
        
        func fireNegativeSentimentPixel(with model: Feedback.Model) {
            
        }
    }
}
