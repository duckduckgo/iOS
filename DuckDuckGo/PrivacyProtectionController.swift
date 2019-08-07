//
//  PrivacyProtectionController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import UIKit
import Core

protocol PrivacyProtectionDelegate: class {

    func omniBarTextTapped()

    func reload(scripts: Bool)

}

class PrivacyProtectionController: ThemableNavigationController {

    weak var privateProtectionDelegate: PrivacyProtectionDelegate?

    weak var omniDelegate: OmniBarDelegate!
    weak var siteRating: SiteRating?
    var omniBarText: String?
    var errorText: String?

    private var storageCache = AppDependencyProvider.shared.storageCache.current

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.isHidden = isPad
        popoverPresentationController?.backgroundColor = UIColor(white: 240/255, alpha: 1.0)

        if !storageCache.hasData {
            showBlockerListError()
        } else if let errorText = errorText {
            showError(withText: errorText)
        } else if siteRating == nil {
            showError(withText: UserText.unknownErrorOccurred)
        } else {
            showInitialScreen()
        }

    }

    private func showError(withText errorText: String) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "Error") as? PrivacyProtectionErrorController else { return }
        controller.errorText = errorText
        pushViewController(controller, animated: true)
    }

    private func showBlockerListError() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "Error") as? PrivacyProtectionErrorController else { return }
        controller.errorText = UserText.privacyProtectionReloadBlockerLists
        controller.delegate = self
        pushViewController(controller, animated: true)
    }

    private func showInitialScreen() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "InitialScreen")
            as? PrivacyProtectionOverviewController else { return }
        pushViewController(controller, animated: true)
        updateViewControllers()
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.title = siteRating?.domain
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        viewController.navigationItem.rightBarButtonItem = doneButton
        super.pushViewController(viewController, animated: animated)
    }

    func updateSiteRating(_ siteRating: SiteRating?) {
        self.siteRating = siteRating
        updateViewControllers()
    }

    func updateViewControllers() {
        guard let siteRating = siteRating else { return }

        viewControllers.forEach {
            guard let infoDisplaying = $0 as? PrivacyProtectionInfoDisplaying else { return }
            infoDisplaying.using(siteRating: siteRating, configuration: storageCache.configuration)
        }
    }

    @objc func done() {
        dismiss(animated: true)
    }

}

// Only use case just now is blocker lists not having downloaded
extension PrivacyProtectionController: PrivacyProtectionErrorDelegate {

    func canTryAgain(controller: PrivacyProtectionErrorController) -> Bool {
        return true
    }

    func tryAgain(controller: PrivacyProtectionErrorController) {
        AppDependencyProvider.shared.storageCache.update { [weak self] newCache in
            self?.handleBlockerListsLoaderResult(controller, newCache)
        }
    }

    private func handleBlockerListsLoaderResult(_ controller: PrivacyProtectionErrorController, _ newCache: StorageCache?) {
        DispatchQueue.main.async {
            if let newCache = newCache {
                self.storageCache = newCache
                controller.dismiss(animated: true)
                self.privateProtectionDelegate?.reload(scripts: true)
            } else {
                controller.resetTryAgain()
            }
        }
    }

}

extension PrivacyProtectionController: UIPopoverPresentationControllerDelegate {

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
    }

}
