//
//  NewTabPageModel.swift
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

final class NewTabPageModel: ObservableObject {

    @Published private(set) var isIntroMessageVisible: Bool
    @Published private(set) var isOnboarding: Bool

    private let appSettings: AppSettings

    init(appSettings: AppSettings = AppDependencyProvider.shared.appSettings) {
        self.appSettings = appSettings
        
        isIntroMessageVisible = appSettings.newTabPageIntroMessageEnabled ?? false
        isOnboarding = false
    }

    func increaseIntroMessageCounter() {
        appSettings.newTabPageIntroMessageSeenCount += 1
        if appSettings.newTabPageIntroMessageSeenCount >= 3 {
            appSettings.newTabPageIntroMessageEnabled = false
        }
    }

    func dismissIntroMessage() {
        appSettings.newTabPageIntroMessageEnabled = false
        isIntroMessageVisible = false
    }

    func startOnboarding() {
        isOnboarding = true
    }

    func finishOnboarding() {
        isOnboarding = false
    }
}
