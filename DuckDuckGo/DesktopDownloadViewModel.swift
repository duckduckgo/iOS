//
//  DesktopDownloadViewModel.swift
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

import Foundation
import UIKit

final class DesktopDownloadViewModel: ObservableObject {
    
    static let defaultURL = URL(string: "https://duckduckgo.com/")!
    static let prefix = "https://"
    
    private var platform: DesktopDownloadPlatform
    @Published var browserDetails: DesktopDownloadPlatformConstants
    
    var downloadURL: URL {
        guard let url = URL(string: "\(Self.prefix)\(browserDetails.downloadURL)") else { return Self.defaultURL }
        return url
    }
    
    init(platform: DesktopDownloadPlatform) {
        self.platform = platform
        self.browserDetails = .init(platform: platform)
    }
    
    func copyLink() {
        UIPasteboard.general.url = downloadURL
    }
    
    func switchPlatform() {
        self.platform = (platform == .mac) ? .windows : .mac
        self.browserDetails = .init(platform: platform)
    }
    
}
