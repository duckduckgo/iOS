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

protocol ContextualOnboardingPresenting {
    func presentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewControllerType)
}

final class ContextualOnboardingPresenter: ContextualOnboardingPresenting {
    private let variantManager: VariantManager
    private let daxDialogsFactory: ContextualDaxDialogsFactory

    init(variantManager: VariantManager, daxDialogsFactory: ContextualDaxDialogsFactory = ExistingLogicContextualDaxDialogsFactory()) {
        self.variantManager = variantManager
        self.daxDialogsFactory = daxDialogsFactory
    }

    func presentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewControllerType) {
        if variantManager.isSupported(feature: .newOnboardingIntro) {
            presentExperimentContextualOnboarding(for: spec, in: vc)
        } else {
            presentControlContextualOnboarding(for: spec, in: vc)
        }
    }

}

// MARK: - Private

private extension ContextualOnboardingPresenter {

    func presentControlContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewControllerType) {
        vc.performSegue(withIdentifier: "DaxDialog", sender: spec)
    }

    func presentExperimentContextualOnboarding(for spec: DaxDialogs.BrowsingSpec, in vc: TabViewControllerType) {

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

        // Before presenting a new dialog, remove any existing ones.
        vc.daxDialogsStackView.arrangedSubviews.filter({ $0 != vc.webViewContainerView }).forEach {
            vc.daxDialogsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        // Ask the Dax Dialogs Factory for a view for the given spec
        let controller = daxDialogsFactory.makeView(for: spec) { [weak vc] in
            guard let vc, let daxController = vc.daxContextualOnboardingController else { return }

            // Collapse stack view and remove dax controller
            animate(daxController: daxController, visible: false) { _ in
                vc.daxDialogsStackView.removeArrangedSubview(daxController.view)
                vc.removeChild(daxController)
            }
        }
        controller.view.isHidden = true
        controller.view.alpha = 0

        vc.insertChild(controller, in: vc.daxDialogsStackView, at: 0)
        vc.daxContextualOnboardingController = controller

        animate(daxController: controller, visible: true)
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
