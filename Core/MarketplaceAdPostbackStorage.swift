//
//  MarketplaceAdPostbackStorage.swift
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

/// A protocol defining the storage for marketplace ad postback data.
protocol MarketplaceAdPostbackStorage {

    /// A Boolean value indicating whether the user is a returning user.
    ///
    /// If the value is `nil`, it means the storage was never set.
    var isReturningUser: Bool? { get }

    /// Updates the stored value indicating whether the user is a returning user.
    ///
    /// - Parameter value: A Boolean value indicating whether the user is a returning user.
    func updateReturningUserValue(_ value: Bool)
}

/// A concrete implementation of `MarketplaceAdPostbackStorage` that uses `UserDefaults` for storage.
struct UserDefaultsMarketplaceAdPostbackStorage: MarketplaceAdPostbackStorage {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var isReturningUser: Bool? {
        userDefaults.isReturningUser
    }

    func updateReturningUserValue(_ value: Bool) {
        userDefaults.isReturningUser = value
    }
}

private extension UserDefaults {
    enum Keys {
        static let isReturningUser = "marketplaceAdPostback.isReturningUser"
    }

    var isReturningUser: Bool? {
        get { object(forKey: Keys.isReturningUser) as? Bool }
        set { set(newValue, forKey: Keys.isReturningUser) }
    }
}
