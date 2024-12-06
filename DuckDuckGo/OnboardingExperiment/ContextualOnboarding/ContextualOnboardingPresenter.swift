//
//  ContextualOnboardingPresenter.swift
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
import BrowserServicesKit
import Core

// Typealias for TabViewControllerType used for testing and Contextual Onboarding Delegate
typealias TabViewOnboardingDelegate = TabViewControllerType & ContextualOnboardingDelegate

// MARK: - Contextual Onboarding Presenter

protocol ContextualOnboardingPresenting {
    func presentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewOnboardingDelegate)
    func dismissContextualOnboardingIfNeeded(from vc: TabViewOnboardingDelegate)
}

final class ContextualOnboardingPresenter: ContextualOnboardingPresenting {
    private let variantManager: VariantManager
    private let daxDialogsFactory: ContextualDaxDialogsFactory
    private let appSettings: AppSettings

    init(
        variantManager: VariantManager,
        daxDialogsFactory: ContextualDaxDialogsFactory,
        appSettings: AppSettings = AppUserDefaults()
    ) {
        self.variantManager = variantManager
        self.daxDialogsFactory = daxDialogsFactory
        self.appSettings = appSettings
    }

    func presentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewOnboardingDelegate) {
        presentExperimentContextualOnboarding(for: spec, in: vc)
    }

    func dismissContextualOnboardingIfNeeded(from vc: TabViewOnboardingDelegate) {
        guard let daxContextualOnboarding = vc.daxContextualOnboardingController else { return }
        remove(daxController: daxContextualOnboarding, fromParent: vc)
    }

}

// MARK: - Private

private extension ContextualOnboardingPresenter {

    func presentControlContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewOnboardingDelegate) {
        vc.performSegue(withIdentifier: "DaxDialog", sender: spec)
    }

    func presentExperimentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewOnboardingDelegate) {

        // Before presenting a new dialog, remove any existing ones.
        vc.daxDialogsStackView.arrangedSubviews.filter({ $0 != vc.webViewContainerView }).forEach {
            vc.daxDialogsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // Adjust message hand emoji based on address bar position
        let platformSpecificMessage = spec.message.replacingOccurrences(
            of: "☝️",
            with: appSettings.currentAddressBarPosition == .bottom ? "👇" : "☝️"
        )
        let platformSpecificSpec = spec.withUpdatedMessage(platformSpecificMessage)
        // Ask the Dax Dialogs Factory for a view for the given spec
        let controller = daxDialogsFactory.makeView(for: platformSpecificSpec, delegate: vc, onSizeUpdate: { [weak vc] in
            if #unavailable(iOS 16.0) {
                // For iOS 15 and below invalidate the intrinsic content size manually so the UIKit view will re-size accordingly to SwiftUI view.
                vc?.daxContextualOnboardingController?.view.invalidateIntrinsicContentSize()
            }
        })
        controller.view.isHidden = true
        controller.view.alpha = 0

        vc.insertChild(controller, in: vc.daxDialogsStackView, at: 0)
        vc.daxContextualOnboardingController = controller

        animate(daxController: controller, visible: true)
    }

    func remove(daxController: UIViewController, fromParent parent: TabViewOnboardingDelegate) {
        animate(daxController: daxController, visible: false) { _ in
            parent.daxDialogsStackView.removeArrangedSubview(daxController.view)
            parent.removeChild(daxController)
            parent.daxContextualOnboardingController = nil
        }
    }

    func animate(daxController: UIViewController, visible isVisible: Bool, onCompletion: ((Bool) -> Void)? = nil) {
        daxController.view.isHidden = !isVisible
        UIView.animate(
            withDuration: 0.3,
            animations: {
                daxController.view.alpha = isVisible ? 1 : 0
                daxController.parent?.view.layoutIfNeeded()
            },
            completion: onCompletion
        )
    }

}

// MARK: - Helpers

private extension UIViewController {

    func insertChild(_ childController: UIViewController, in stackView: UIStackView, at index: Int) {
        addChild(childController)
        stackView.insertArrangedSubview(childController.view, at: index)
        childController.didMove(toParent: self)
    }

    func removeChild(_ childController: UIViewController) {
        childController.willMove(toParent: nil)
        childController.view.removeFromSuperview()
        childController.removeFromParent()
    }

}

// MARK: - TabViewControllerType

protocol TabViewControllerType: UIViewController {
    var daxDialogsStackView: UIStackView { get }
    var webViewContainerView: UIView { get }
    var daxContextualOnboardingController: UIViewController? { get set }
}

extension TabViewController: TabViewControllerType {

    var daxDialogsStackView: UIStackView {
        containerStackView
    }

    var webViewContainerView: UIView {
        webViewContainer
    }
}
