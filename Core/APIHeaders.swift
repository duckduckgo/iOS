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
            let fullVersion = "\(appVersion.versionNumber).\(appVersion.buildNumber)"
            let osVersion = UIDevice.current.systemVersion
            let userAgent = "ddg_ios/\(fullVersion) (\(appVersion.identifier); iOS \(osVersion))"
            var headers = Alamofire.SessionManager.defaultHTTPHeaders
            headers[Name.userAgent] = userAgent
            return headers
        }
    }
    
}
