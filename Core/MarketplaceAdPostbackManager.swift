//
//  MarketplaceAdPostbackManager.swift
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

public protocol MarketplaceAdPostbackManaging {

    /// Updates the install postback based on the return user measurement
    ///
    /// This method determines whether the user is a returning user or a new user and sends the appropriate postback value:
    /// - If the user is returning, it sends the `appLaunchReturningUser` postback value.
    /// - If the user is new, it sends the `appLaunchNewUser` postback value.
    ///
    /// > For the time being, we're also sending `lockPostback` to `true`.
    /// > More information can be found [here](https://app.asana.com/0/0/1208126219488943/1208289369964239/f).
    func sendAppLaunchPostback()
}

public struct MarketplaceAdPostbackManager: MarketplaceAdPostbackManaging {
    private let returningUserMeasurement: ReturnUserMeasurement
    private let updater: MarketplaceAdPostbackUpdating

    internal init(returningUserMeasurement: ReturnUserMeasurement = KeychainReturnUserMeasurement(),
                  updater: MarketplaceAdPostbackUpdating = MarketplaceAdPostbackUpdater()) {
        self.returningUserMeasurement = returningUserMeasurement
        self.updater = updater
    }

    public init() {
        self.returningUserMeasurement = KeychainReturnUserMeasurement()
        self.updater = MarketplaceAdPostbackUpdater()
    }

    public func sendAppLaunchPostback() {
        if returningUserMeasurement.isReturningUser {
            updater.updatePostback(.installReturningUser, lockPostback: true)
        } else {
            updater.updatePostback(.installNewUser, lockPostback: true)
        }
    }
}
