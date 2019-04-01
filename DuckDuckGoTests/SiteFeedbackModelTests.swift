//
//  SiteFeedbackModelTests.swift
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

class SiteFeedbackModelTests: XCTestCase {

    struct Constants {
        static let url = "http://example.com"
        static let message = "A message"
    }

    private var feedbackSenderStub = FeedbackSenderStub()
    private var testee: SiteFeedbackModel!

    override func setUp() {
        testee = SiteFeedbackModel(feedbackSender: feedbackSenderStub)
    }

    func testWhenInitThenDefaultValuesAreCorrect() {
        XCTAssertNil(testee.url)
        XCTAssertNil(testee.message)
    }

    func testWhenSiteBrokenAndHasUrlAndMessageThenCanSubmit() {
        testee.url = Constants.url
        testee.message = Constants.message
        XCTAssertTrue(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsNilThenCanNotSubmit() {
        testee.url = nil
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsEmptyThenCanNotSubmit() {
        testee.url = ""
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndUrlIsWhitespaceThenCanNotSubmit() {
        testee.url = " "
        testee.message = Constants.message
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsNilThenCanNotSubmit() {
        testee.url = Constants.url
        testee.message = nil
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsEmptyThenCanNotSubmit() {
        testee.url = Constants.url
        testee.message = ""
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenSiteBrokenAndMessageIsWhitespaceThenCanNotSubmit() {
        testee.url = Constants.url
        testee.message = " "
        XCTAssertFalse(testee.canSubmit())
    }

    func testWhenBrokenSiteSubmittedThenCorrectSubmissionMade() {
        testee.url = Constants.url
        testee.message = Constants.message
        testee.submit()

        XCTAssertTrue(feedbackSenderStub.brokenSiteSubmitted)
        XCTAssertEqual(Constants.url, feedbackSenderStub.url)
        XCTAssertEqual(Constants.message, feedbackSenderStub.message)
    }

    func testWhenCannotSubmitThenNoSubmissionMade() {
        testee.submit()
        XCTAssertFalse(feedbackSenderStub.brokenSiteSubmitted)
    }

    class FeedbackSenderStub: FeedbackSender {

        var brokenSiteSubmitted = false

        var url: String?
        var message: String?

        func submitBrokenSite(url: String, message: String) {
            brokenSiteSubmitted = true
            self.url = url
            self.message = message
        }
        
        func submitPositiveSentiment(message: String) {}
        func submitNegativeSentiment(message: String, url: String?, model: Feedback.Model) {}
        
        func firePositiveSentimentPixel() {}
        func fireNegativeSentimentPixel(with model: Feedback.Model) {}
    }
}
