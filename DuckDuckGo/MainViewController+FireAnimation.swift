//
//  MainViewController+FireAnimation.swift
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

import Core
import SwiftUI

extension MainViewController {

    func forgetAllWithAnimation(showNextDaxDialog: Bool = false) {
        let spid = Instruments.shared.startTimedEvent(.clearingData)
        Pixel.fire(pixel: .forgetAllExecuted)

        Task { @MainActor in

            var dataClearingFinished = false
            var preClearingUIUpdatesFinished = false

            // Run this in parallel
            Task {
                self.tabManager.prepareCurrentTabForDataClearing()
                self.stopAllOngoingDownloads()
                self.forgetTabs()
                self.refreshUIAfterClear()
                preClearingUIUpdatesFinished = true

                await self.forgetData()

                // Add some sleep here to test the indterimnate state
                // try? await Task.sleep(interval: 10.0)

                Instruments.shared.endTimedEvent(for: spid)
                dataClearingFinished = true
            }

            await fireButtonAnimator.animate()

            if !preClearingUIUpdatesFinished {
                Pixel.fire(pixel: .debugAnimationFinishedBeforeClearing)
            }

            if !dataClearingFinished {
                Pixel.fire(pixel: .debugAnimationFinishedBeforeClearing)
            }

            if !dataClearingFinished, let controller = showFireProgress() {
                while !dataClearingFinished {
                    await Task.yield()
                }
                controller.dismiss(animated: true)
            }

            // MARK: post-clearing animation tasks

            print("***", #function, "starting post-clearing tasks", Date().timeIntervalSince1970)
            ActionMessageView.present(message: UserText.actionForgetAllDone,
                                      presentationLocation: .withBottomBar(andAddressBarBottom: appSettings.currentAddressBarPosition.isBottom))

            privacyProDataReporter.saveFireCount()

            if showNextDaxDialog {
                self.newTabPageViewController?.showNextDaxDialog()
            } else if KeyboardSettings().onNewTab &&
                        // If we're showing the Add to Dock dialog prevent address bar to become first responder.
                        !self.contextualOnboardingLogic.isShowingAddToDockDialog {
                self.enterSearch()
            }

            if self.variantManager.isContextualDaxDialogsEnabled {
                DaxDialogs.shared.clearedBrowserData()
            }
        }
    }

    func showFireProgress() -> UIViewController? {
        print("***", #function, "IN")
        guard let view = UIHostingController(rootView: FireProgressView(), ignoreSafeArea: true).view else { return nil
        }

        view.frame = self.view.frame

        let controller = UIViewController()
        controller.view.blur(style: .systemThinMaterial)
        controller.view.translatesAutoresizingMaskIntoConstraints = true
        controller.view.addSubview(view)
        controller.modalPresentationStyle = .overCurrentContext
        controller.modalTransitionStyle = .crossDissolve
        present(controller, animated: true)

        print("***", #function, "OUT")
        return controller
    }

}
