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

    /// Updates the stored value for the returning user state.
    ///
    /// This method updates the storage with the current state of the user (returning or new).
    /// Since `ReturnUserMeasurement` will always return `isReturningUser` as `false` after the first run,
    /// `MarketplaceAdPostbackManaging` maintains its own storage of the user's state across app launches.
    func updateReturningUserValue()
}

public struct MarketplaceAdPostbackManager: MarketplaceAdPostbackManaging {
    private let storage: MarketplaceAdPostbackStorage
    private let updater: MarketplaceAdPostbackUpdating
    private let returningUserMeasurement: ReturnUserMeasurement

    internal init(storage: MarketplaceAdPostbackStorage = UserDefaultsMarketplaceAdPostbackStorage(),
                  updater: MarketplaceAdPostbackUpdating = MarketplaceAdPostbackUpdater(),
                  returningUserMeasurement: ReturnUserMeasurement = KeychainReturnUserMeasurement()) {
        self.storage = storage
        self.updater = updater
        self.returningUserMeasurement = returningUserMeasurement
    }

    public init() {
        self.storage = UserDefaultsMarketplaceAdPostbackStorage()
        self.updater = MarketplaceAdPostbackUpdater()
        self.returningUserMeasurement = KeychainReturnUserMeasurement()
    }

    public func sendAppLaunchPostback() {
        guard let isReturningUser = storage.isReturningUser else { return }

        if isReturningUser {
            updater.updatePostback(.installReturningUser, lockPostback: true)
        } else {
            updater.updatePostback(.installNewUser, lockPostback: true)
        }
    }

    public func updateReturningUserValue() {
        storage.updateReturningUserValue(returningUserMeasurement.isReturningUser)
    }
}
