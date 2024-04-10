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

final class CrashCollectionOnboarding: NSObject {

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        self.viewModel = CrashCollectionOnboardingViewModel(appSettings: appSettings)
        super.init()
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

        if #available(iOS 16.0, *) {
            let identifier = UISheetPresentationController.Detent.Identifier("crashReportHidden")
            controller.sheetPresentationController?.detents = [.custom(identifier: identifier, resolver: { _ in return 540 }), .large()]
            controller.sheetPresentationController?.delegate = self

            detailsCancellable = viewModel.$isShowingReport
                .dropFirst()
                .removeDuplicates()
                .sink { [weak controller] isShowingReport in
                    guard let sheet = controller?.sheetPresentationController else {
                        return
                    }
                    let newDetentIdentifier: UISheetPresentationController.Detent.Identifier = isShowingReport ? .large : identifier
                    DispatchQueue.main.async {
                        sheet.animateChanges {
                            sheet.selectedDetentIdentifier = newDetentIdentifier
                        }
                    }
                }
        }

        viewModel.setReportDetails(with: payloads)
        viewModel.onDismiss = { [weak self, weak viewController] shouldSend in
            if let shouldSend {
                completion(shouldSend)
            }
            viewController?.dismiss(animated: true)
            self?.detailsCancellable = nil
        }

        viewController.present(controller, animated: true)
    }

    private var shouldPresentOnboarding: Bool {
        appSettings.sendCrashLogs == nil
    }

    private let appSettings: AppSettings
    private let viewModel: CrashCollectionOnboardingViewModel
    private var detailsCancellable: AnyCancellable?
}

@available(iOS 16.0, *)
extension CrashCollectionOnboarding: UISheetPresentationControllerDelegate {
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        viewModel.isShowingReport = sheetPresentationController.selectedDetentIdentifier == .large
    }
}
