//
//  OnboardingIntroViewController.swift
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

import SwiftUI

final class OnboardingIntroViewController: UIHostingController<OnboardingView>, Onboarding {
    weak var delegate: OnboardingDelegate?
    private let viewModel: OnboardingIntroViewModel

    init(onboardingPixelReporter: OnboardingPixelReporting) {
        viewModel = OnboardingIntroViewModel(pixelReporter: onboardingPixelReporter)
        let rootView = OnboardingView(model: viewModel)
        super.init(rootView: rootView)
        
        viewModel.onCompletingOnboardingIntro = { [weak self] in
            guard let self else { return }
            self.delegate?.onboardingCompleted(controller: self)
        }
    }

    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
