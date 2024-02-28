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
import Common

/// View controller used for `Privacy Dashboard` or `Report broken site`, the web content is chosen at init time setting the correct `initMode`
class PrivacyDashboardViewController: UIViewController {
    
    @IBOutlet private(set) weak var webView: WKWebView!
    
    private let privacyDashboardController: PrivacyDashboardController
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let contentBlockingManager: ContentBlockerRulesManager
    public var breakageAdditionalInfo: BreakageAdditionalInfo?
    
    // TODO!
    var source: BrokenSiteReport.Source { privacyDashboardController.dashboardMode == .report ? .appMenu : .dashboard }

    private let brokenSiteReporter: BrokenSiteReporter = {
        BrokenSiteReporter(pixelHandler: { parameters in
            Pixel.fire(pixel: .brokenSiteReport,
                       withAdditionalParameters: parameters,
                       allowedQueryReservedCharacters: BrokenSiteReport.allowedQueryReservedCharacters)
        }, keyValueStoring: UserDefaults.standard)
    }()
    
    init?(coder: NSCoder,
          privacyInfo: PrivacyInfo?,
          dashboardMode: PrivacyDashboardMode,
          privacyConfigurationManager: PrivacyConfigurationManaging,
          contentBlockingManager: ContentBlockerRulesManager,
          breakageAdditionalInfo: BreakageAdditionalInfo?) {
        self.privacyDashboardController = PrivacyDashboardController(privacyInfo: privacyInfo,
                                                                     dashboardMode: dashboardMode,
                                                                     privacyConfigurationManager: privacyConfigurationManager)
        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager
        self.breakageAdditionalInfo = breakageAdditionalInfo
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

// MARK: - PrivacyDashboardControllerDelegate

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

// MARK: - PrivacyDashboardNavigationDelegate

extension PrivacyDashboardViewController: PrivacyDashboardNavigationDelegate {
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboard.PrivacyDashboardController, didSetHeight height: Int) {
        // The size received in iPad is wrong, shane will sort this out soon.
        // preferredContentSize.height = CGFloat(height)
    }
    
    func privacyDashboardControllerDidTapClose(_ privacyDashboardController: PrivacyDashboardController) {
        privacyDashboardCloseHandler()
    }
}

// MARK: - PrivacyDashboardReportBrokenSiteDelegate

extension PrivacyDashboardViewController: PrivacyDashboardReportBrokenSiteDelegate {
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    reportBrokenSiteDidChangeProtectionSwitch protectionState: ProtectionState) {
        privacyDashboardProtectionSwitchChangeHandler(state: protectionState)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboard.PrivacyDashboardController,
                                    didRequestSubmitBrokenSiteReportWithCategory category: String, description: String) {
                
        do {
            let report = try makeBrokenSiteReport(category: category, description: description)
            try brokenSiteReporter.report(report)
        } catch {
            os_log("Failed to generate or send the broken site report: %@", type: .error, error.localizedDescription)
        }
        
        ActionMessageView.present(message: UserText.feedbackSumbittedConfirmation)
        privacyDashboardCloseHandler()
    }
}

extension PrivacyDashboardViewController: UIPopoverPresentationControllerDelegate {}

extension PrivacyDashboardViewController {
    
    struct BreakageAdditionalInfo {
        let currentURL: URL
        let httpsForced: Bool
        let ampURLString: String
        let urlParametersRemoved: Bool
        let isDesktop: Bool
        let error: Error?
        let httpStatusCode: Int?
    }
    
    enum BrokenSiteReportError: Error {
        case failedToFetchTheCurrentWebsiteInfo
    }

    private func makeBrokenSiteReport(category: String, description: String) throws -> BrokenSiteReport {
        
        guard let privacyInfo = privacyDashboardController.privacyInfo,
              let breakageAdditionalInfo = breakageAdditionalInfo  else {
            throw BrokenSiteReportError.failedToFetchTheCurrentWebsiteInfo
        }
        
        let blockedTrackerDomains = privacyInfo.trackerInfo.trackersBlocked.compactMap { $0.domain }
        let protectionsState = privacyConfigurationManager.privacyConfig.isFeature(.contentBlocking,
                                                                                   enabledForDomain: breakageAdditionalInfo.currentURL.host)

        var errors: [Error]?
        var statusCodes: [Int]?
        if let error = breakageAdditionalInfo.error {
            errors = [error]
        }
        if let httpStatusCode = breakageAdditionalInfo.httpStatusCode {
            statusCodes = [httpStatusCode]
        }

        return BrokenSiteReport(siteUrl: breakageAdditionalInfo.currentURL,
                               category: category,
                               description: description,
                               osVersion: "\(ProcessInfo().operatingSystemVersion.majorVersion)",
                               manufacturer: "Apple",
                               upgradedHttps: breakageAdditionalInfo.httpsForced,
                               tdsETag: ContentBlocking.shared.contentBlockingManager.currentMainRules?.etag ?? "",
                               blockedTrackerDomains: blockedTrackerDomains,
                               installedSurrogates: privacyInfo.trackerInfo.installedSurrogates.map { $0 },
                               isGPCEnabled: AppDependencyProvider.shared.appSettings.sendDoNotSell,
                               ampURL: breakageAdditionalInfo.ampURLString,
                               urlParametersRemoved: breakageAdditionalInfo.urlParametersRemoved,
                               protectionsState: protectionsState,
                               reportFlow: source,
                               siteType: breakageAdditionalInfo.isDesktop ? .desktop : .mobile,
                               atb: StatisticsUserDefaults().atb ?? "",
                               model: UIDevice.current.model,
                               errors: errors,
                               httpStatusCodes: statusCodes)
    }
}
