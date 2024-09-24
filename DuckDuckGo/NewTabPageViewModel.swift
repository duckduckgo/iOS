//
//  NewTabPageViewModel.swift
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

final class NewTabPageViewModel: ObservableObject {

    @Published private(set) var isIntroMessageVisible: Bool
    @Published private(set) var isOnboarding: Bool
    @Published var isShowingSettings: Bool

    private var introDataStorage: NewTabPageIntroDataStoring
    private let pixelFiring: PixelFiring.Type

    init(introDataStorage: NewTabPageIntroDataStoring = NewTabPageIntroDataUserDefaultsStorage(),
         pixelFiring: PixelFiring.Type = Pixel.self) {
        self.introDataStorage = introDataStorage
        self.pixelFiring = pixelFiring

        isIntroMessageVisible = introDataStorage.newTabPageIntroMessageEnabled ?? false
        isOnboarding = false
        isShowingSettings = false
    }

    func introMessageDisplayed() {
        pixelFiring.fire(.newTabPageMessageDisplayed, withAdditionalParameters: [:])

        introDataStorage.newTabPageIntroMessageSeenCount += 1
        if introDataStorage.newTabPageIntroMessageSeenCount >= 3 {
            introDataStorage.newTabPageIntroMessageEnabled = false
        }
    }

    func dismissIntroMessage() {
        pixelFiring.fire(.newTabPageMessageDismissed, withAdditionalParameters: [:])

        introDataStorage.newTabPageIntroMessageEnabled = false
        isIntroMessageVisible = false
    }

    func customizeNewTabPage() {
        pixelFiring.fire(.newTabPageCustomize, withAdditionalParameters: [:])
        isShowingSettings = true
    }

    func startOnboarding() {
        isOnboarding = true
    }

    func finishOnboarding() {
        isOnboarding = false
    }
}
