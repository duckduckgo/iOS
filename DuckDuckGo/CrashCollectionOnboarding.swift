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

import Combine
import Foundation
import SwiftUI
import BrowserServicesKit

enum CrashCollectionOptInStatus: String {
    case undetermined, optedIn, optedOut
}

final class CrashCollectionOnboardingViewController: UIHostingController<CrashCollectionOnboardingView> {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        return .portrait
    }
}

final class CrashCollectionOnboarding: NSObject {
    
    private var featureFlagger: FeatureFlagger

    init(appSettings: AppSettings,
         featureFlagger: FeatureFlagger = AppDependencyProvider.shared.featureFlagger) {
        self.appSettings = appSettings
        self.viewModel = CrashCollectionOnboardingViewModel(appSettings: appSettings)
        self.featureFlagger = featureFlagger
        super.init()
    }
    
    // If the user's crash report opt in status should be reset to unknown upon next release,
    // increment this value by 1
    private let crashCollectionShouldRevertOptedInStatusTriggerTargetValue: Int = 1

    @MainActor
    func presentOnboardingIfNeeded(for payloads: [Data], from viewController: UIViewController, sendReport: @escaping () -> Void) {
        let isCurrentlyPresenting = viewController.presentedViewController != nil
        
        // Note: DO NOT TURN THIS ON until updated screens for the opt-in prompt and screen for reviewing the kinds of data
        // we collect are updated (project coming soon)
        if featureFlagger.isFeatureOn(.crashReportOptInStatusResetting) {
            if appSettings.crashCollectionOptInStatus == .optedIn &&
                appSettings.crashCollectionShouldRevertOptedInStatusTrigger < crashCollectionShouldRevertOptedInStatusTriggerTargetValue {

                appSettings.crashCollectionOptInStatus = .undetermined
                appSettings.crashCollectionShouldRevertOptedInStatusTrigger = crashCollectionShouldRevertOptedInStatusTriggerTargetValue
            }
        }
        
        guard shouldPresentOnboarding, !isCurrentlyPresenting else {
            if appSettings.crashCollectionOptInStatus == .optedIn {
                sendReport()
            }
            return
        }

        let controller = CrashCollectionOnboardingViewController(rootView: CrashCollectionOnboardingView(model: viewModel))

        if #available(iOS 16.0, *) {
            let identifier = UISheetPresentationController.Detent.Identifier("crashReportHidden")
            controller.sheetPresentationController?.detents = [.custom(identifier: identifier, resolver: { _ in return 560 }), .large()]
            controller.sheetPresentationController?.delegate = self

            detailsCancellable = viewModel.$isViewExpanded
                .dropFirst()
                .removeDuplicates()
                .sink { [weak controller] isViewExpanded in
                    guard let sheet = controller?.sheetPresentationController else {
                        return
                    }
                    let newDetentIdentifier: UISheetPresentationController.Detent.Identifier = isViewExpanded ? .large : identifier
                    DispatchQueue.main.async {
                        sheet.animateChanges {
                            sheet.selectedDetentIdentifier = newDetentIdentifier
                        }
                    }
                }
        }

        viewModel.setReportDetails(with: payloads)
        viewModel.onDismiss = { [weak self, weak viewController] optInStatus in
            if optInStatus == .optedIn {
                sendReport()
            }
            viewController?.dismiss(animated: true)
            self?.detailsCancellable = nil
        }

        viewController.present(controller, animated: true)
    }

    private var shouldPresentOnboarding: Bool {
        appSettings.crashCollectionOptInStatus == .undetermined
    }

    private let appSettings: AppSettings
    private let viewModel: CrashCollectionOnboardingViewModel
    private var detailsCancellable: AnyCancellable?
}

@available(iOS 16.0, *)
extension CrashCollectionOnboarding: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        if sheetPresentationController.selectedDetentIdentifier == .large {
            // When the view is expanded manually, only show the report after a slight delay in order to avoid UI glitches
            // See also `CrashCollectionOnboardingViewModel.isReportVisible`.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.viewModel.showReport()
            }
        } else {
            viewModel.hideReport(animated: false)
        }
    }
}
