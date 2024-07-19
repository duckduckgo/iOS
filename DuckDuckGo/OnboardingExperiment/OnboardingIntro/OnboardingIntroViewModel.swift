//
//  OnboardingIntroViewModel.swift
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
import class UIKit.UIApplication

final class OnboardingIntroViewModel: ObservableObject {
    @Published private(set) var state: OnboardingView.ViewState = .landing

    var onCompletingOnboardingIntro: (() -> Void)?
    private let pixelReporter: OnboardingIntroPixelReporting
    private let urlOpener: URLOpener

    init(pixelReporter: OnboardingIntroPixelReporting = OnboardingPixelReporter(), urlOpener: URLOpener = UIApplication.shared) {
        self.pixelReporter = pixelReporter
        self.urlOpener = urlOpener
    }

    func onAppear() {
        state = .onboarding(.startOnboardingDialog)
        pixelReporter.trackOnboardingIntroImpression()
    }

    func startOnboardingAction() {
        state = .onboarding(.browsersComparisonDialog)
        pixelReporter.trackBrowserComparisonImpression()
    }

    func setDefaultBrowserAction() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            urlOpener.open(url)
        }
        pixelReporter.trackChooseBrowserCTAAction()
        onCompletingOnboardingIntro?()
    }

    func cancelSetDefaultBrowserAction() {
        onCompletingOnboardingIntro?()
    }
}
