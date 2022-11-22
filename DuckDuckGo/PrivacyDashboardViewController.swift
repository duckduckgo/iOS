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
import PrivacyDashboard

class PrivacyDashboardViewController: UIViewController {
    
    @IBOutlet private(set) weak var webView: WKWebView!
    
    public weak var tabViewController: TabViewController?
    
    private let privacyDashboardController: PrivacyDashboardController
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let contentBlockingManager: ContentBlockerRulesManager

    init?(coder: NSCoder,
          privacyInfo: PrivacyInfo?,
          privacyConfigurationManager: PrivacyConfigurationManaging,
          contentBlockingManager: ContentBlockerRulesManager) {
        self.privacyDashboardController = PrivacyDashboardController(privacyInfo: privacyInfo)
        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager
        
        super.init(coder: coder)
        
        self.privacyDashboardController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        privacyDashboardController.setup(for: webView)
        privacyDashboardController.preferredLocale = Bundle.main.preferredLocalizations.first
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        privacyDashboardController.cleanUp()
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        privacyDashboardController.didFinishRulesCompilation()
        privacyDashboardController.updatePrivacyInfo(privacyInfo)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let brokenSiteScreen = navController.topViewController as? ReportBrokenSiteViewController {
            brokenSiteScreen.brokenSiteInfo = tabViewController?.getCurrentWebsiteInfo()
        }
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
        view.backgroundColor = theme.privacyDashboardWebviewBackgroundColor
        privacyDashboardController.theme = privacyDashboardTheme(from: theme)
    }
    
    private func privacyDashboardTheme(from theme: Theme) -> PrivacyDashboardTheme {
        switch theme.name {
        case .light: return .light
        case .dark: return .dark
        default: return .light
        }
    }
}

extension PrivacyDashboardViewController: PrivacyDashboardControllerDelegate {
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didChangeProtectionSwitch isEnabled: Bool) {
        privacyDashboardProtectionSwitchChangeHandler(enabled: isEnabled)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didRequestOpenUrlInNewTab url: URL) {
        guard let mainViewController = presentingViewController as? MainViewController else { return }
        
        dismiss(animated: true) {
            mainViewController.loadUrlInNewTab(url, inheritedAttribution: nil)
        }
    }
    
    func privacyDashboardControllerDidTapClose(_ privacyDashboardController: PrivacyDashboardController) {
        privacyDashboardCloseTappedHandler()
    }
    
    func privacyDashboardControllerDidRequestShowReportBrokenSite(_ privacyDashboardController: PrivacyDashboardController) {
        performSegue(withIdentifier: "ReportBrokenSite", sender: self)
    }
}

extension PrivacyDashboardViewController: UIPopoverPresentationControllerDelegate { }
