//
//  AppTrackerDataSetProvider.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit

final public class AppTrackerDataSetProvider: EmbeddedDataProvider {

    public struct Constants {
        public static let embeddedDataETag = "\"c9e76dac56186b93f609cc9f1e8c2c0a\""
        public static let embeddedDataSHA = "5735d4459ecdec68b70d75a3effb5c1f8f8bc18af2d05c7fd2ecae4e1d530627"
    }

    public var embeddedDataEtag: String {
        return Constants.embeddedDataETag
    }

    public var embeddedData: Data {
        return Self.loadEmbeddedAsData()
    }

    static var embeddedUrl: URL {
        if let url = Bundle.main.url(forResource: "trackerData", withExtension: "json") {
            return url
        }
        
        return Bundle(for: Self.self).url(forResource: "trackerData", withExtension: "json")!
    }

    static func loadEmbeddedAsData() -> Data {
        let json = try? Data(contentsOf: embeddedUrl)
        return json!
    }
}
