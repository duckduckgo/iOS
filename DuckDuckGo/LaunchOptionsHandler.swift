//
//  LaunchOptionsHandler.swift
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

public final class LaunchOptionsHandler {
    private static let isUITesting = "isUITesting"
    private static let isOnboardingcompleted = "isOnboardingCompleted"
    private static let appVariantName = "currentAppVariant"

    private let launchArguments: [String]
    private let userDefaults: UserDefaults

    public init(launchArguments: [String] = ProcessInfo.processInfo.arguments, userDefaults: UserDefaults = .app) {
        self.launchArguments = launchArguments
        self.userDefaults = userDefaults
    }

    public var isUITesting: Bool {
        launchArguments.contains(Self.isUITesting)
    }

    public var isOnboardingCompleted: Bool {
        userDefaults.string(forKey: Self.isOnboardingcompleted) == "true"
    }

    public var appVariantName: String? {
        sanitisedEnvParameter(string: userDefaults.string(forKey: Self.appVariantName))
    }

    private func sanitisedEnvParameter(string: String?) -> String? {
        guard let string, string != "null" else { return nil }
        return string
    }
}

// MARK: - LaunchOptionsHandler + VariantManager

extension LaunchOptionsHandler: VariantNameOverriding {

    public var overriddenAppVariantName: String? {
        guard isUITesting else { return nil }
        return appVariantName
    }

}
