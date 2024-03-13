//
//  FaviconSourcesProvider.swift
//  Core
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

import Foundation

protocol FaviconSourcesProvider {

    func mainSource(forDomain: String) -> URL?

    func additionalSources(forDomain: String) -> [URL]

}

class DefaultFaviconSourcesProvider: FaviconSourcesProvider {

    enum ImageNames: String {

        case appleTouch = "apple-touch-icon.png"
        case favicon = "favicon.ico"

    }

    func mainSource(forDomain domain: String) -> URL? {
        return imageSource(forDomain: domain, imageName: ImageNames.appleTouch, secure: true)
    }

    func additionalSources(forDomain domain: String) -> [URL] {
        return [
            imageSource(forDomain: domain, imageName: .favicon, secure: true),
            imageSource(forDomain: domain, imageName: .favicon, secure: false)
        ].compactMap { $0 }
    }

    private func imageSource(forDomain domain: String, imageName: ImageNames, secure: Bool) -> URL? {
        return URL(string: (secure ? "https" : "http") + "://" + domain + "/" + imageName.rawValue)
    }

}
