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
import PrivacyDashboard

class PrivacyDashboardViewController: UIViewController {
    
    @IBOutlet private(set) weak var webView: WKWebView!
    
    weak var privacyInfo: PrivacyInfo?
    private var privacyDashboardLogic: PrivacyDashboardLogic!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupPrivacyDashboardLogic()
        setupPrivacyDashboardLogicHandlers()
        
        privacyDashboardLogic.setup(for: webView)
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        privacyDashboardLogic.cleanUp()
    }
    
    private func setupPrivacyDashboardLogic() {
        privacyDashboardLogic = PrivacyDashboardLogic(privacyInfo: privacyInfo!)
    }
    
    private func setupPrivacyDashboardLogicHandlers() {
        privacyDashboardLogic.onProtectionSwitchChange = { [weak self] isEnabled in
            self?.privacyDashboardProtectionSwitchChangeHandler(enabled: isEnabled)
        }
        
        privacyDashboardLogic.onCloseTapped = { [weak self] in
            self?.privacyDashboardCloseTappedHandler()
        }
        
        privacyDashboardLogic.onShowReportBrokenSiteTapped = { [weak self] in
            guard let mainViewController = self?.presentingViewController as? MainViewController else { return }
            
            self?.dismiss(animated: true) {
                mainViewController.launchReportBrokenSite()
            }
        }
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        privacyDashboardLogic.didFinishRulesCompilation()
        privacyDashboardLogic.updatePrivacyInfo(privacyInfo)
    }
}

private extension PrivacyDashboardViewController {
    
    func privacyDashboardProtectionSwitchChangeHandler(enabled: Bool) {
        guard let domain = privacyDashboardLogic.privacyInfo?.url.host else { return }
        
        let privacyConfiguration = ContentBlocking.privacyConfigurationManager.privacyConfig
        
        if enabled {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
        }
        
        ContentBlocking.contentBlockingManager.scheduleCompilation()
        
        privacyDashboardLogic.didStartRulesCompilation()
    }
    
    func privacyDashboardCloseTappedHandler() {
        dismiss(animated: true)
    }
}

extension PrivacyDashboardViewController: Themable {
    
    func decorate(with theme: Theme) {
        privacyDashboardLogic.themeName = theme.name.rawValue
        view.backgroundColor = theme.backgroundColor
    }
}

extension PrivacyDashboardViewController: UIPopoverPresentationControllerDelegate { }
