//
//  SubscriptionService.swift
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import Common

public struct SubscriptionService: APIService {

    public static let logger: OSLog = .subscriptionService
    public static let session = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration)
    }()
    public static let baseURL = URL(string: "https://subscriptions-dev.duckduckgo.com/api")!

    // MARK: -

    public static func getSubscriptionInfo(token: String) async -> Result<GetSubscriptionInfoResponse, APIServiceError> {
        await executeAPICall(method: "GET", endpoint: "subscription", headers: makeAuthorizationHeader(for: token))
    }

    public struct GetSubscriptionInfoResponse: Decodable {
        public let productId: String
        public let startedAt: Date
        public let expiresOrRenewsAt: Date
        public let platform: String
        public let status: String
    }
}
