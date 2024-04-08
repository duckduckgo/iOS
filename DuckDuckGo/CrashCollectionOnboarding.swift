//
//  CrashCollectionOnboarding.swift
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
import SwiftUI

final class CrashCollectionOnboarding {

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        self.viewModel = CrashCollectionOnboardingViewModel(appSettings: appSettings)
    }

    @MainActor
    func presentOnboardingIfNeeded(for payloads: [Data], from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        let isCurrentlyPresenting = viewController.presentedViewController != nil
        guard shouldPresentOnboarding, !isCurrentlyPresenting else {
            completion(appSettings.sendCrashLogs == true)
            return
        }

        let controller = UIHostingController(rootView: CrashCollectionOnboardingView(model: viewModel))
        controller.isModalInPresentation = true

        viewModel.setReportDetails(with: payloads)
        viewModel.onDismiss = { [weak viewController] shouldSend in
            if let shouldSend {
                completion(shouldSend)
            }
            viewController?.dismiss(animated: true)
        }

        viewController.present(controller, animated: true)
    }

    private var shouldPresentOnboarding: Bool {
        appSettings.sendCrashLogs == nil
    }

    private let appSettings: AppSettings
    private let viewModel: CrashCollectionOnboardingViewModel
}
