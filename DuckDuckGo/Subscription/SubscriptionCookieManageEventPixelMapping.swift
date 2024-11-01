//
//  SubscriptionCookieManageEventPixelMapping.swift
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
import Common
import Core
import Subscription

public final class SubscriptionCookieManageEventPixelMapping: EventMapping<SubscriptionCookieManagerEvent> {

    public init() {
        super.init { event, _, _, _ in
            let pixel: Pixel.Event = {
                switch event {
                case .errorHandlingAccountDidSignInTokenIsMissing:
                    return .privacyProSubscriptionCookieMissingTokenOnSignIn
                case .subscriptionCookieRefreshedWithAccessToken:
                    return .privacyProSubscriptionCookieRefreshedWithAccessToken
                case .subscriptionCookieRefreshedWithEmptyValue:
                    return .privacyProSubscriptionCookieRefreshedWithEmptyValue
                case .failedToSetSubscriptionCookie:
                    return .privacyProSubscriptionCookieFailedToSetSubscriptionCookie
                }
            }()

            Pixel.fire(pixel: pixel)

        }
    }

    override init(mapping: @escaping EventMapping<SubscriptionCookieManagerEvent>.Mapping) {
        fatalError("Use init()")
    }
}
