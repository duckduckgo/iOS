//
//  PreserveLoginsWorker.swift
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

struct PreserveLoginsWorker {

    private struct Constants {
        static let timeForAutofillToBlockFireproofPrompt = 10.0
    }

    weak var controller: UIViewController?

    func handleLoginDetection(detectedURL: URL?, currentURL: URL?, isAutofillEnabled: Bool, saveLoginPromptLastDismissed: Date?, saveLoginPromptIsPresenting: Bool) -> Bool {
        guard let detectedURL = detectedURL, let currentURL = currentURL else { return false }
        guard let domain = detectedURL.host, domainOrPathDidChange(detectedURL, currentURL) else { return false }
        guard !PreserveLogins.shared.isAllowed(fireproofDomain: domain) else { return false }
        if isAutofillEnabled && autofillShouldBlockPrompt(saveLoginPromptLastDismissed, saveLoginPromptIsPresenting: saveLoginPromptIsPresenting) {
            return false
        }
        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first, window.subviews.contains(where: { $0 is ActionMessageView }) {
            // if an ActionMessageView is currently displayed wait before prompting to fireproof
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.promptToFireproof(domain)
            }
        } else {
            promptToFireproof(domain)
        }
        return true
    }

    /// Block prompt if SaveLoginViewController is currently (or about to be) presented or has been presented in the last 10 seconds
    func autofillShouldBlockPrompt(_ saveLoginPromptLastDismissed: Date?, saveLoginPromptIsPresenting: Bool) -> Bool {
        if controller?.presentedViewController is SaveLoginViewController || saveLoginPromptIsPresenting {
            return true
        }
        if let saveLoginPromptLastDismissed = saveLoginPromptLastDismissed,
           Date().timeIntervalSince(saveLoginPromptLastDismissed) < Constants.timeForAutofillToBlockFireproofPrompt {
            return true
        }
        return false
    }

    func handleUserEnablingFireproofing(forDomain domain: String) {
        addDomain(domain)
    }

    func handleUserDisablingFireproofing(forDomain domain: String) {
        removeDomain(domain)
    }

    private func domainOrPathDidChange(_ detectedURL: URL, _ currentURL: URL) -> Bool {
        return currentURL.host != detectedURL.host || currentURL.path != detectedURL.path
    }

    private func promptToFireproof(_ domain: String) {
        guard let controller = controller else { return }
        PreserveLoginsAlert.showFireproofWebsitePrompt(usingController: controller, forDomain: domain) {
            self.addDomain(domain)
        }
    }

    private func addDomain(_ domain: String) {
        guard let controller = controller else { return }
        PreserveLogins.shared.addToAllowed(domain: domain)
        Favicons.shared.loadFavicon(forDomain: domain, intoCache: .fireproof, fromCache: .tabs)
        PreserveLoginsAlert.showFireproofEnabledMessage(usingController: controller, worker: self, forDomain: domain)
    }

    private func removeDomain(_ domain: String) {
        guard let controller = controller else { return }
        PreserveLogins.shared.remove(domain: domain)
        Favicons.shared.removeFireproofFavicon(forDomain: domain)
        PreserveLoginsAlert.showFireproofDisabledMessage(usingController: controller, worker: self, forDomain: domain)
    }

}
