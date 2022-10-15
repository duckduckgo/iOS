//
//  PrivacyDashboardViewController.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import WebKit
import Combine
import Core
import BrowserServicesKit
import PrivacyDashboardResources

class PrivacyDashboardViewController: UIViewController {
    
    @IBOutlet private(set) weak var webView: WKWebView!
    
    private let privacyDashboardController: PrivacyDashboardController
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let contentBlockingManager: ContentBlockerRulesManager

    init?(coder: NSCoder,
          privacyInfo: PrivacyInfo?,
          privacyConfigurationManager: PrivacyConfigurationManaging,
          contentBlockingManager: ContentBlockerRulesManager) {
        privacyDashboardController = PrivacyDashboardController(privacyInfo: privacyInfo)
        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager
        
        super.init(coder: coder)
        
        setupPrivacyDashboardControllerHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        privacyDashboardController.setup(for: webView)
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        privacyDashboardController.cleanUp()
    }
    
    private func setupPrivacyDashboardControllerHandlers() {
        privacyDashboardController.onProtectionSwitchChange = { [weak self] isEnabled in
            self?.privacyDashboardProtectionSwitchChangeHandler(enabled: isEnabled)
        }
        
        privacyDashboardController.onCloseTapped = { [weak self] in
            self?.privacyDashboardCloseTappedHandler()
        }
        
        privacyDashboardController.onShowReportBrokenSiteTapped = { [weak self] in
            guard let mainViewController = self?.presentingViewController as? MainViewController else { return }
            
            self?.dismiss(animated: true) {
                mainViewController.launchReportBrokenSite()
            }
        }
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        privacyDashboardController.didFinishRulesCompilation()
        privacyDashboardController.updatePrivacyInfo(privacyInfo)
    }
}

private extension PrivacyDashboardViewController {
    
    func privacyDashboardProtectionSwitchChangeHandler(enabled: Bool) {
        guard let domain = privacyDashboardController.privacyInfo?.url.host else { return }
        
        let privacyConfiguration = privacyConfigurationManager.privacyConfig
        
        if enabled {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
        }
        
        contentBlockingManager.scheduleCompilation()
        
        privacyDashboardController.didStartRulesCompilation()
    }
    
    func privacyDashboardCloseTappedHandler() {
        dismiss(animated: true)
    }
}

extension PrivacyDashboardViewController: Themable {
    
    func decorate(with theme: Theme) {
        privacyDashboardController.themeName = theme.name.rawValue
        view.backgroundColor = theme.backgroundColor
    }
}

extension PrivacyDashboardViewController: UIPopoverPresentationControllerDelegate { }
