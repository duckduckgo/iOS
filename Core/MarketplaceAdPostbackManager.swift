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
            updater.updatePostback(.appLaunchReturningUser, lockPostback: true)
        } else {
            updater.updatePostback(.appLaunchNewUser, lockPostback: true)
        }
    }
}
