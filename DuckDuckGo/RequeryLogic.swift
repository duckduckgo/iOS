//
//  RequeryLogic.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

import UIKit
import Core
import Networking

class RequeryLogic {
    
    private enum SerpState {
        case notLoaded
        case loaded(String)
    }
    
    private enum PixelValue {
        case sameQuery
        case changedQuery
    }

    private let userAgentManager: UserAgentManager = DefaultUserAgentManager.shared
    private var serpState: SerpState = .notLoaded

    func onNewNavigation(url: URL) {
        guard let query = url.searchQuery else {
            serpState = .notLoaded
            return
        }
        
        onQuerySubmitted(newQuery: query)
    }
    
    func onRefresh() {
        guard case .loaded = serpState else { return }
        
        sendPixel(value: .sameQuery)
    }
    
    private func onQuerySubmitted(newQuery: String) {
        guard case let .loaded(query) = serpState else {
            serpState = .loaded(newQuery)
            return
        }
        
        if query == newQuery {
            sendPixel(value: .sameQuery)
        } else {
            serpState = .loaded(newQuery)
            sendPixel(value: .changedQuery)
        }
    }
    
    private func sendPixel(value: PixelValue) {
        
        let pixel: Pixel.Event
        switch value {
        case .sameQuery:
            pixel = .serpRequerySame
        case .changedQuery:
            pixel = .serpRequeryNew
        }
        
        let headers = APIRequest.Headers(userAgent: userAgentManager.userAgent(isDesktop: false))
        Pixel.fire(pixel: pixel, forDeviceType: nil, withHeaders: headers, onComplete: { _ in })
    }
}
