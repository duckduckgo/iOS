//
//  DuckPlayerViewModel.swift
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

import Combine
import Foundation

final class DuckPlayerViewModel: ObservableObject {
    
    let videoID: String
    let baseURL: String = "https://www.youtube-nocookie.com/embed/"
    let parameters: [String: String] = ["autoplay": "1", "rel": "0", "playsinline": "1"]
    
    init(videoID: String) {
        self.videoID = videoID
    }
    
    func getVideoURL() -> URL? {
        let queryString = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        return URL(string: "\(baseURL)\(videoID)?\(queryString)")
    }
    
    func onFirstAppear() {
        // Add any initialization logic here
    }
}
