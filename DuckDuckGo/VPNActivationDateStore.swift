//
//  VPNActivationDateStore.swift
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

protocol VPNActivationDateStore {

    func setActivationDateIfNecessary()
    func daysSinceActivation() -> Int?

    func updateLastActiveDate()
    func daysSinceLastActive() -> Int?

}

struct DefaultVPNActivationDateStore: VPNActivationDateStore {

    private enum Constants {
        static let networkProtectionActivationDateKey = "com.duckduckgo.network-protection.activation-date"
        static let networkProtectionLastActiveDateKey = "com.duckduckgo.network-protection.last-active-date"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .networkProtectionGroupDefaults) {
        self.userDefaults = userDefaults
    }

    func setActivationDateIfNecessary() {
        if userDefaults.double(forKey: Constants.networkProtectionActivationDateKey) != 0 {
            return
        }

        updateActivationDate(Date())
    }

    func daysSinceActivation() -> Int? {
        let timestamp = userDefaults.double(forKey: Constants.networkProtectionActivationDateKey)

        if timestamp == 0 {
            return nil
        }

        let activationDate = Date(timeIntervalSinceReferenceDate: timestamp)
        return daysSince(date: activationDate)
    }

    func updateLastActiveDate() {
        userDefaults.set(Date().timeIntervalSinceReferenceDate, forKey: Constants.networkProtectionLastActiveDateKey)
    }

    func daysSinceLastActive() -> Int? {
        let timestamp = userDefaults.double(forKey: Constants.networkProtectionLastActiveDateKey)

        if timestamp == 0 {
            return nil
        }

        let activationDate = Date(timeIntervalSinceReferenceDate: timestamp)
        return daysSince(date: activationDate)
    }

    // MARK: - Resetting

    func removeDates() {
        userDefaults.removeObject(forKey: Constants.networkProtectionActivationDateKey)
    }

    // MARK: - Updating

    func updateActivationDate(_ date: Date) {
        userDefaults.set(date.timeIntervalSinceReferenceDate, forKey: Constants.networkProtectionActivationDateKey)
    }

    private func daysSince(date storedDate: Date) -> Int? {
        let numberOfDays = Calendar.current.dateComponents([.day], from: storedDate, to: Date())
        return numberOfDays.day
    }

}
