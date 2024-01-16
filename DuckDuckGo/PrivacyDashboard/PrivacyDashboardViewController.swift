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

/// View controller used for `Privacy Dasboard` or `Report broken site`, the web content is chosen at init time setting the correct `initMode`
class PrivacyDashboardViewController: UIViewController {
    
    /// Type of web page displayed
    enum Mode {
        case privacyDashboard
        case reportBrokenSite
    }

    @IBOutlet private(set) weak var webView: WKWebView!
    
    private let initMode: Mode
    private let privacyDashboardController: PrivacyDashboardController
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let contentBlockingManager: ContentBlockerRulesManager
    public var brokenSiteInfo: BrokenSiteInfo?
    
    var source: BrokenSiteInfo.Source {
        initMode == .reportBrokenSite ? .appMenu : .dashboard
    }

    init?(coder: NSCoder,
          privacyInfo: PrivacyInfo?,
          privacyConfigurationManager: PrivacyConfigurationManaging,
          contentBlockingManager: ContentBlockerRulesManager,
          initMode: Mode) {
        self.privacyDashboardController = PrivacyDashboardController(privacyInfo: privacyInfo)
        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager
        self.initMode = initMode
        
        super.init(coder: coder)
        
        self.privacyDashboardController.privacyDashboardDelegate = self
        self.privacyDashboardController.privacyDashboardNavigationDelegate = self
        self.privacyDashboardController.privacyDashboardReportBrokenSiteDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        privacyDashboardController.setup(for: webView, reportBrokenSiteOnly: initMode == Mode.reportBrokenSite ? true : false)
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

    private func privacyDashboardProtectionSwitchChangeHandler(state: ProtectionState) {
        
        dismiss(animated: true)
        
        guard let domain = privacyDashboardController.privacyInfo?.url.host else { return }
        
        let privacyConfiguration = privacyConfigurationManager.privacyConfig
        let pixelParam = ["trigger_origin": state.eventOrigin.screen.rawValue,
                          "source": source.rawValue]
        if state.isProtected {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
            Pixel.fire(pixel: .dashboardProtectionAllowlistRemove, withAdditionalParameters: pixelParam)
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
            Pixel.fire(pixel: .dashboardProtectionAllowlistAdd, withAdditionalParameters: pixelParam)
        }
        
        contentBlockingManager.scheduleCompilation()
    }
    
    private func privacyDashboardCloseHandler() {
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

    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didChangeProtectionSwitch protectionState: ProtectionState) {
        privacyDashboardProtectionSwitchChangeHandler(state: protectionState)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didRequestOpenUrlInNewTab url: URL) {
        guard let mainViewController = presentingViewController as? MainViewController else { return }
        
        dismiss(animated: true) {
            mainViewController.loadUrlInNewTab(url, inheritedAttribution: nil)
        }
    }
    
    func privacyDashboardControllerDidRequestShowReportBrokenSite(_ privacyDashboardController: PrivacyDashboardController) {
        Pixel.fire(pixel: .privacyDashboardReportBrokenSite)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboard.PrivacyDashboardController,
                                    didRequestOpenSettings target: PrivacyDashboard.PrivacyDashboardOpenSettingsTarget) {
        guard let mainViewController = presentingViewController as? MainViewController else { return }
        
        dismiss(animated: true) {
            switch target {
            case .cookiePopupManagement:
                mainViewController.segueToSettingsCookiePopupManagement()
            default:
                mainViewController.segueToSettings()
            }
        }
    }
}

extension PrivacyDashboardViewController: PrivacyDashboardNavigationDelegate {
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboard.PrivacyDashboardController, didSetHeight height: Int) {
        // The size received in iPad is wrong, shane will sort this out soon.
        // preferredContentSize.height = CGFloat(height)
    }
    
    func privacyDashboardControllerDidTapClose(_ privacyDashboardController: PrivacyDashboardController) {
        privacyDashboardCloseHandler()
    }
}

extension PrivacyDashboardViewController: PrivacyDashboardReportBrokenSiteDelegate {
        
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, reportBrokenSiteDidChangeProtectionSwitch protectionState: ProtectionState) {
        privacyDashboardProtectionSwitchChangeHandler(state: protectionState)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboard.PrivacyDashboardController, didRequestSubmitBrokenSiteReportWithCategory category: String, description: String) {
        
        guard let brokenSiteInfo = brokenSiteInfo else {
            assertionFailure("brokenSiteInfo not initialised")
            return
        }
        
        brokenSiteInfo.send(with: category, description: description, source: source)
        ActionMessageView.present(message: UserText.feedbackSumbittedConfirmation)
        privacyDashboardCloseHandler()
    }
}

extension PrivacyDashboardViewController: UIPopoverPresentationControllerDelegate {}
