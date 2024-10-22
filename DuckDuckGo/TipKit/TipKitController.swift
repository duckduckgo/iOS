//
//  TipKitController.swift
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
import os.log
import TipKit

public protocol TipKitControlling {
    @available(iOS 17.0, *)
    func configureTipKit()

    @available(iOS 17.0, *)
    func resetTipKitOnNextAppLaunch()
}

typealias TipKitAppEventHandler = TipKitController

public final class TipKitController {

    private let logger: Logger
    private let userDefaults: UserDefaults

    private var resetTipKitOnNextLaunch: Bool {
        get {
            userDefaults.bool(forKey: "resetTipKitOnNextLaunch")
        }

        set {
            userDefaults.set(newValue, forKey: "resetTipKitOnNextLaunch")
        }
    }

    public init(logger: Logger,
                userDefaults: UserDefaults) {

        self.logger = logger
        self.userDefaults = userDefaults
    }

    @available(iOS 17.0, macOS 14.0, *)
    public func configureTipKit(_ configuration: [Tips.ConfigurationOption] = []) {
        do {
            if resetTipKitOnNextLaunch {
                resetTipKit()
                resetTipKitOnNextLaunch = false
            }

            try Tips.configure(configuration)

            logger.debug("TipKit initialized")
        } catch {
            logger.error("Failed to initialize TipKit: \(error)")
        }
    }

    @available(iOS 17.0, macOS 14.0, *)
    private func resetTipKit() {
        do {
            try Tips.resetDatastore()

            logger.debug("TipKit reset")
        } catch {
            logger.debug("Failed to reset TipKit: \(error)")
        }
    }

    /// Resets TipKit
    ///
    /// One thing that's not documented as of 2024-10-09 is that resetting TipKit must happen before it's configured.
    /// When trying to reset it after it's configured we get `TipKit.TipKitError(value: TipKit.TipKitError.Value.tipsDatastoreAlreadyConfigured)`.
    /// In order to make things work for us we set a user defaults value that ensures TipKit will be reset on next
    /// app launch instead of directly trying to reset it here.
    ///
    @available(iOS 17.0, *)
    public func resetTipKitOnNextAppLaunch() {
        resetTipKitOnNextLaunch = true
        logger.debug("TipKit will reset on next app launch")
    }
}
