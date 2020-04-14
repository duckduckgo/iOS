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
    
    unowned var controller: UIViewController
    
    func handleLoginDetection(detectedURL: URL?, currentURL: URL?) {
        guard let detectedURL = detectedURL, let currentURL = currentURL else { return }
        guard let domain = detectedURL.host, domainOrPathDidChange(detectedURL, currentURL) else { return }
        promptToFireproof(domain)
    }
    
    private func domainOrPathDidChange(_ detectedURL: URL, _ currentURL: URL) -> Bool {
        return currentURL.host != detectedURL.host || currentURL.path != detectedURL.path
    }
    
    private func promptToFireproof(_ domain: String) {
        PreserveLoginsAlert.showFireproofWebsitePrompt(usingController: controller) {
            self.addDomain(domain)
        }
    }
    
    private func addDomain(_ domain: String) {
        PreserveLogins.shared.addToAllowed(domain: domain)
        PreserveLoginsAlert.showFireproofToast(usingController: controller, forDomain: domain)
    }
    
}
