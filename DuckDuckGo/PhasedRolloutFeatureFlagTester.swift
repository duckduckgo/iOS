//
//  PhasedRolloutFeatureFlagTester.swift
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
import BrowserServicesKit
import Core

protocol PhasedRolloutPixelSender: AnyObject {
    func sendPixel(completion: @escaping (Error?) -> Void)
}

final class DefaultPhasedRolloutPixelSender: PhasedRolloutPixelSender {
    func sendPixel(completion: @escaping (Error?) -> Void) {
        Pixel.fire(pixel: .incrementalRolloutTest) { error in
            completion(error)
        }
    }
}

final class PhasedRolloutFeatureFlagTester {

    enum Constants {
        static let hasSentPixelKey = "network-protection.incremental-feature-flag-test.has-sent-pixel"
    }

    static let shared = PhasedRolloutFeatureFlagTester()

    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let pixelSender: PhasedRolloutPixelSender
    private let userDefaults: UserDefaults

    init(privacyConfigurationManager: PrivacyConfigurationManaging = ContentBlocking.shared.privacyConfigurationManager,
         pixelSender: PhasedRolloutPixelSender = DefaultPhasedRolloutPixelSender(),
         userDefaults: UserDefaults = .standard) {
        self.privacyConfigurationManager = privacyConfigurationManager
        self.pixelSender = pixelSender
        self.userDefaults = userDefaults
    }

    func sendFeatureFlagEnabledPixelIfNecessary(completion: (() -> Void)? = nil) {
        guard !hasSentPixelBefore(), privacyConfigurationManager.privacyConfig.isSubfeatureEnabled(IncrementalRolloutTestSubfeature2.rollout) else {
            completion?()
            return
        }

        markPixelAsSent()

        pixelSender.sendPixel { [weak self] error in
            if error != nil {
                self?.markPixelAsUnsent()
            }

            completion?()
        }
    }

    private func hasSentPixelBefore() -> Bool {
        return userDefaults.bool(forKey: Constants.hasSentPixelKey)
    }

    private func markPixelAsSent() {
        userDefaults.setValue(true, forKey: Constants.hasSentPixelKey)
    }

    private func markPixelAsUnsent() {
        userDefaults.removeObject(forKey: Constants.hasSentPixelKey)
    }

}
