//
//  WaitlistExtensions.swift
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
import Networking

extension Waitlist {

    init() {
        self.init(
            store: WaitlistKeychainStore(waitlistIdentifier: Self.identifier),
            request: ProductWaitlistRequest(productName: Self.apiProductName)
        )
    }

    var onBackgroundTaskSubmissionError: ((Error) -> Void)? {
        { error in
            Pixel.fire(pixel: .backgroundTaskSubmissionFailed, error: error)
        }
    }
}

extension WaitlistViewModel {

    convenience init(waitlist: Waitlist) {
        let waitlistType = type(of: waitlist)
        let notificationService: NotificationService? = waitlist.isWaitlistRemoved ? nil : UNUserNotificationCenter.current()
        self.init(
            waitlistRequest: ProductWaitlistRequest(productName: waitlistType.apiProductName),
            waitlistStorage: WaitlistKeychainStore(waitlistIdentifier: waitlistType.identifier),
            notificationService: notificationService,
            downloadURL: waitlistType.downloadURL
        )
    }
}

extension ProductWaitlistRequest {

    convenience init(productName: String) {
        let makeHTTPRequest: ProductWaitlistMakeHTTPRequest = { url, method, body, completion in
            guard let httpMethod = APIRequest.HTTPMethod(rawValue: method) else {
                fatalError("The HTTP method is invalid")
            }
            
            let configuration = APIRequest.Configuration(url: url,
                                                         method: httpMethod,
                                                         body: body)
            let request = APIRequest(configuration: configuration)
            request.fetch { response, error in
                completion(response?.data, error)
            }
        }
        self.init(productName: productName, makeHTTPRequest: makeHTTPRequest)
    }
}
