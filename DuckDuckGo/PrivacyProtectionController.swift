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
import BrowserServicesKit
import WebKit
import PrivacyDashboard

protocol PrivacyProtectionDelegate: AnyObject {

    func omniBarTextTapped()

    func reload(scripts: Bool)

    func getCurrentWebsiteInfo() -> BrokenSiteInfo
}

class PrivacyProtectionController: ThemableNavigationController {

    weak var privacyProtectionDelegate: PrivacyProtectionDelegate?

    weak var omniDelegate: OmniBarDelegate!
    weak var privacyInfo: PrivacyInfo?
    
    weak var privacyDashboard: NewPrivacyDashboardViewController?
    
    var omniBarText: String?
  
    private var storageCache = AppDependencyProvider.shared.storageCache.current
    private var privacyConfig = ContentBlocking.privacyConfigurationManager.privacyConfig

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        navigationBar.isHidden = AppWidthObserver.shared.isLargeWidth
        
        popoverPresentationController?.backgroundColor = UIColor.nearlyWhite

        showInitialScreen()
    }

    private func showInitialScreen() {
        let controller = NewPrivacyDashboardViewController(privacyInfo: privacyInfo)
        
        privacyDashboard = controller
         
        pushViewController(controller, animated: true)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        viewController.navigationItem.rightBarButtonItem = doneButton
        super.pushViewController(viewController, animated: animated)
    }
    
    func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        self.privacyInfo = privacyInfo
        privacyDashboard?.updatePrivacyInfo(privacyInfo)
    }

    @objc func done() {
        dismiss(animated: true)
    }

}

extension PrivacyProtectionController: UIPopoverPresentationControllerDelegate { }
