//
//  APIHeaders.swift
//  Core
//
//  Created by duckduckgo on 14/05/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import Foundation
import Alamofire

public class APIHeaders {
    
    struct Name {
        static let userAgent = "User-Agent"
        static let etag = "ETag"
    }
    
    private let appVersion: AppVersion
    
    public init(appVersion: AppVersion = AppVersion()) {
        self.appVersion = appVersion
    }

    public var defaultHeaders: HTTPHeaders  {
        get {
            var headers = Alamofire.SessionManager.defaultHTTPHeaders
            let agent = "ddg_ios/\(appVersion.versionNumber).\(appVersion.buildNumber) (\(appVersion.identifier); iOS \(UIDevice.current.systemVersion))"
            headers[Name.userAgent] = agent
            return headers
        }
    }
    
}
