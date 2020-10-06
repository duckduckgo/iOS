//
//  APIHeaders.swift
//  Core
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

public typealias HTTPHeaders = [String: String]

public class APIHeaders {

    struct Name {
        static let acceptEncoding = "Accept-Encoding"
        static let acceptLanguage = "Accept-Language"
        static let userAgent = "User-Agent"
        static let etag = "ETag"
        static let ifNoneMatch = "If-None-Match"
    }

    private let appVersion: AppVersion

    public init(appVersion: AppVersion = AppVersion.shared) {
        self.appVersion = appVersion
    }

    public var defaultHeaders: HTTPHeaders {
        let acceptEncoding = "gzip;q=1.0, compress;q=0.5"
        let languages = Locale.preferredLanguages.prefix(6)
        let acceptLanguage = languages.enumerated().map { index, language in
            let q = 1.0 - (Double(index) * 0.1)
            return "\(language);q=\(q)"
        }.joined(separator: ", ")
        
        return [
            Name.acceptEncoding: acceptEncoding,
            Name.acceptLanguage: acceptLanguage,
            Name.userAgent: userAgent
        ]
    }

    public var userAgent: String {
        let osVersion = UIDevice.current.systemVersion
        return "ddg_ios/\(appVersion.versionAndBuildNumber) (\(appVersion.identifier); iOS \(osVersion))"
    }

    public func defaultHeaders(with etag: String?) -> HTTPHeaders {
        guard let etag = etag else {
            return defaultHeaders
        }

        return defaultHeaders.merging([Name.ifNoneMatch: etag]) { (_, new) in new }
    }

    public func addHeaders(to request: inout URLRequest) {
        request.addValue(Name.userAgent, forHTTPHeaderField: userAgent)
    }

}
