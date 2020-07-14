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
    
    weak var controller: UIViewController?
    
    func handleLoginDetection(detectedURL: URL?, currentURL: URL?) -> Bool {
        guard let detectedURL = detectedURL, let currentURL = currentURL else { return false }
        guard let domain = detectedURL.host, domainOrPathDidChange(detectedURL, currentURL) else { return false }
        guard !PreserveLogins.shared.isAllowed(fireproofDomain: domain) else { return false }
        promptToFireproof(domain)
        return true
    }
    
    func handleUserFireproofing(forDomain domain: String) {
        guard let controller = controller else { return }
        PreserveLoginsAlert.showConfirmFireproofWebsite(usingController: controller, forDomain: domain) {
            Pixel.fire(pixel: .browsingMenuFireproof)
            self.addDomain(domain)
        }
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
        Favicons.shared.loadFavicon(forDomain: domain, intoCache: .bookmarks)
        PreserveLoginsAlert.showFireproofToast(usingController: controller, forDomain: domain)
    }
    
}
