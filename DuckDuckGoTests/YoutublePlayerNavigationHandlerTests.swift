//
//  YoutublePlayerNavigationHandlerTests.swift
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

class YoutubePlayerNavigationHandlerTests: XCTestCase {

    func testHtmlTemplatePath() {
        let path = YoutubePlayerNavigationHandler.htmlTemplatePath
        XCTAssertFalse(path.isEmpty, "The htmlTemplatePath should not be empty")
    }
    
    func testMakeDuckPlayerRequestFromOriginalRequest_withValidRequest() {
        let handler = YoutubePlayerNavigationHandler()
        
        let validURL = URL(string: "https://www.youtube.com/watch?v=video_id&t=123")!
        let originalRequest = URLRequest(url: validURL)
        
        let newRequest = handler.makeDuckPlayerRequest(from: originalRequest)
        
        XCTAssertEqual(newRequest.url?.host, "www.youtube-nocookie.com", "The host should be www.youtube-nocookie.com")
        XCTAssertEqual(newRequest.url?.path, "/embed/video_id", "The path should be /embed/video_id")
        XCTAssertEqual(newRequest.url?.query, "start=123", "The query should be start=123")
        XCTAssertEqual(newRequest.httpMethod, "GET", "HTTP method should be GET")
        XCTAssertEqual(newRequest.value(forHTTPHeaderField: "Referer"), "http://localhost/", "Referer should be http://localhost/")
    }

    func testMakeDuckPlayerRequestForVideoID() {
        let handler = YoutubePlayerNavigationHandler()
        let videoID = "video_id"
        let timestamp = "123"
        
        let request = handler.makeDuckPlayerRequest(for: videoID, timestamp: timestamp)
        
        XCTAssertEqual(request.url?.host, "www.youtube-nocookie.com", "The host should be www.youtube-nocookie.com")
        XCTAssertEqual(request.url?.path, "/embed/video_id", "The path should be /embed/video_id")
        XCTAssertEqual(request.url?.query, "t=123", "The query should be t=123")
        XCTAssertEqual(request.httpMethod, "GET", "HTTP method should be GET")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Referer"), "http://localhost/", "Referer should be http://localhost/")
    }

    func testMakeHTMLFromTemplate() {
        let handler = YoutubePlayerNavigationHandler()
        
        let html = handler.makeHTMLFromTemplate()
        
        XCTAssertFalse(html.isEmpty, "The generated HTML should not be empty")
    }
}
