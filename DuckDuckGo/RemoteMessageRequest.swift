//
//  RemoteMessageRequest.swift
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
import Core

public struct RemoteMessageRequest {

    private var endpoint: URL {
        #if DEBUG
        return URL(string: "https://raw.githubusercontent.com/duckduckgo/remote-messaging-config/main/samples/ios/sample1.json")!
        #else
        return URL(string: "https://staticcdn.duckduckgo.com/remotemessaging/config/staging/ios-config.json")!
        #endif
    }

    public init() { }

    public func getRemoteMessage(completionHandler: @escaping (Result<RemoteMessageResponse.JsonRemoteMessagingConfig, RemoteMessageResponse.StatusError>) -> Void) {
        APIRequest.request(url: endpoint, method: .get) { response, error in
            guard let data = response?.data, error == nil else {
                completionHandler(.failure(.noData))
                return
            }

            do {
                let decoder  = JSONDecoder()
                let response = try decoder.decode(RemoteMessageResponse.JsonRemoteMessagingConfig.self, from: data)

                completionHandler(.success(response))
            } catch {
                completionHandler(.failure(.parsingFailed))
            }
        }
    }
}
