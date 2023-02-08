//
//  Waitlist.swift
//  DuckDuckGo
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
import Core
import UserNotifications
import Waitlist

struct MacBrowserWaitlistFeature: WaitlistFeature {
    let identifier: String = "mac"
    var isWaitlistRemoved: Bool = true
    var apiProductName: String = "macosbrowser"
    var downloadURL: URL = AppUrls().macBrowserDownloadURL
}

struct WindowsBrowserWaitlistFeature: WaitlistFeature {
    let identifier: String = "windows"
    var isWaitlistRemoved: Bool = true
    var apiProductName: String = "windowsbrowser"
    var downloadURL: URL = AppUrls().windowsBrowserDownloadURL
}

extension WaitlistHandling {

    init() {
        self.init(
            store: WaitlistKeychainStore(waitlistIdentifier: Self.feature.identifier),
            request: ProductWaitlistRequest(feature: Self.feature)
        )
    }

    var onBackgroundTaskSubmissionError: ((Error) -> Void)? {
        { error in
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
    }
}

extension WaitlistViewModel {

    convenience init(feature: WaitlistFeature) {
        let notificationService: NotificationService? = feature.isWaitlistRemoved ? nil : UNUserNotificationCenter.current()
        self.init(
            waitlistRequest: ProductWaitlistRequest(feature: feature),
            waitlistStorage: WaitlistKeychainStore(waitlistIdentifier: feature.identifier),
            notificationService: notificationService,
            downloadURL: feature.downloadURL
        )
    }
}

extension ProductWaitlistRequest {

    convenience init(feature: WaitlistFeature) {
        let makeHTTPRequest: ProductWaitlistMakeHTTPRequest = { url, method, body, completion in
            guard let httpMethod = APIRequest.HTTPMethod(rawValue: method) else {
                completion(nil, APIRequest.APIRequestError.noResponseOrError)
                return
            }
            APIRequest.request(url: url, method: httpMethod, httpBody: body, completion: { response, error in
                completion(response?.data, error)
            })
        }
        self.init(feature: feature, makeHTTPRequest: makeHTTPRequest)
    }
}
