//
//  SubscriptionEnvironment+Default.swift
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
import Subscription

extension SubscriptionEnvironment {

    public static var `default`: SubscriptionEnvironment {
#if ALPHA || DEBUG
        let environment: SubscriptionEnvironment.ServiceEnvironment = .staging
#else
        let environment: SubscriptionEnvironment.ServiceEnvironment = .production
#endif
        return SubscriptionEnvironment(serviceEnvironment: environment, purchasePlatform: .appStore)
    }
}

extension DefaultSubscriptionManager {

    static public func getSavedOrDefaultEnvironment(userDefaults: UserDefaults) -> SubscriptionEnvironment {
        if let savedEnvironment = loadEnvironmentFrom(userDefaults: userDefaults) {
            return savedEnvironment
        }
        return SubscriptionEnvironment.default
    }
}
