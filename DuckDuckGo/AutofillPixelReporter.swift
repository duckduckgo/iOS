//
//  AutofillPixelReporter.swift
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
import Core
import BrowserServicesKit

final class AutofillPixelReporter {

    @UserDefaultsWrapper(key: .autofillSearchDauDate, defaultValue: .distantPast)
    var autofillSearchDauDate: Date

    @UserDefaultsWrapper(key: .autofillFillDate, defaultValue: .distantPast)
    var autofillFillDate: Date

    @UserDefaultsWrapper(key: .autofillOnboardedUser, defaultValue: false)
    var autofillOnboardedUser: Bool

    private let statisticsStorage: StatisticsStore
    private let secureVault: (any AutofillSecureVault)?

    enum EventType {
        case fill
        case searchDAU
    }

    init(statisticsStorage: StatisticsStore = StatisticsUserDefaults(), secureVault: (any AutofillSecureVault)? = try? AutofillSecureVaultFactory.makeVault(reporter: SecureVaultReporter.shared)) {
        self.statisticsStorage = statisticsStorage
        self.secureVault = secureVault

        createNotificationObservers()

        if shouldFireOnboardedUserPixel() {
            DailyPixel.fire(pixel: .autofillOnboardedUser)
        }
    }

    private func createNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveSearchDAU), name: .searchDAU, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveFillEvent), name: .autofillFillEvent, object: nil)
    }

    @objc
    private func didReceiveSearchDAU() {
        guard !Date().isSameDay(autofillSearchDauDate) else {
            return
        }

        autofillSearchDauDate = Date()

        firePixels(pixelsToFireFor(.searchDAU))
    }

    @objc
    private func didReceiveFillEvent() {
        guard !Date().isSameDay(autofillFillDate) else {
            return
        }

        autofillFillDate = Date()

        firePixels(pixelsToFireFor(.fill))
    }

    func pixelsToFireFor(_ type: EventType) -> [Pixel.Event] {
        var pixelsToFire: [Pixel.Event] = []

        if shouldFireActiveUserPixel() {
            pixelsToFire.append(.autofillActiveUser)
        }

        switch type {
        case .fill:
            pixelsToFire.append(.autofillLoginsStacked)
        case .searchDAU:
            if shouldFireEnabledUserPixel() {
                pixelsToFire.append(.autofillEnabledUser)
            }
        }

        return pixelsToFire
    }

    private func firePixels(_ pixels: [Pixel.Event]) {
        for pixel in pixels {
            switch pixel {
            case .autofillLoginsStacked:
                let bucket = (try? secureVault?.accountsCountBucket()) ?? ""
                DailyPixel.fire(pixel: pixel, withAdditionalParameters: [PixelParameters.countBucket: bucket])
            default:
                DailyPixel.fire(pixel: pixel)
            }
        }
    }

    private func shouldFireActiveUserPixel() -> Bool {
        let today = Date()
        if today.isSameDay(autofillSearchDauDate) && today.isSameDay(autofillFillDate) {
            return true
        }
        return false
    }

    private func shouldFireEnabledUserPixel() -> Bool {
        if Date().isSameDay(autofillSearchDauDate), let count = try? secureVault?.accountsCount(), count >= 10 {
            return true
        }
        return false
    }

    func shouldFireOnboardedUserPixel() -> Bool {
        guard !autofillOnboardedUser, let installDate = statisticsStorage.installDate, UIApplication.shared.isProtectedDataAvailable else {
            return false
        }

        let pastWeek = Date().addingTimeInterval(.days(-7))

        if installDate >= pastWeek {
            if let count = try? secureVault?.accountsCount(), count > 0 {
                autofillOnboardedUser = true
                return true
            }
        } else {
            autofillOnboardedUser = true
        }
        return false
    }

}

extension NSNotification.Name {
    static let autofillFillEvent: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.autofillFillEvent")
}
