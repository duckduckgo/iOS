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

// swiftlint:disable file_length

extension PixelExperiment {

    static var privacyDashboardVariant: PrivacyDashboardVariant {
        switch Self.cohort {
        case .breakageSiteReportingFlowA: return .a
        case .breakageSiteReportingFlowB: return .b
        default: return .control
        }
    }

}

protocol PrivacyDashboardViewControllerDelegate: AnyObject {

    func privacyDashboardViewController(_ privacyDashboardViewController: PrivacyDashboardViewController,
                                        didSelectBreakageCategory breakageCategory: String)
    
}

final class PrivacyDashboardViewController: UIViewController {

    @IBOutlet private(set) weak var webView: WKWebView!

    public var breakageAdditionalInfo: BreakageAdditionalInfo?
    public weak var delegate: PrivacyDashboardViewControllerDelegate?

    private let privacyDashboardController: PrivacyDashboardController
    private let privacyConfigurationManager: PrivacyConfigurationManaging
    private let contentBlockingManager: ContentBlockerRulesManager
    private var privacyDashboardDidTriggerDismiss: Bool = false

    private let brokenSiteReporter: BrokenSiteReporter = {
        BrokenSiteReporter(pixelHandler: { parameters in
            Pixel.fire(pixel: .brokenSiteReport,
                       withAdditionalParameters: parameters,
                       allowedQueryReservedCharacters: BrokenSiteReport.allowedQueryReservedCharacters)
        }, keyValueStoring: UserDefaults.standard)
    }()

    private let toggleProtectionsOffReporter: BrokenSiteReporter = {
        BrokenSiteReporter(pixelHandler: { parameters in
            Pixel.fire(pixel: .protectionToggledOffBreakageReport,
                       withAdditionalParameters: parameters,
                       allowedQueryReservedCharacters: BrokenSiteReport.allowedQueryReservedCharacters)
        }, keyValueStoring: UserDefaults.standard)
    }()

    private let privacyDashboardEvents = EventMapping<PrivacyDashboardEvents> { event, _, parameters, _ in
        let domainEvent: Pixel.Event
        switch event {
        case .showReportBrokenSite: domainEvent = .privacyDashboardReportBrokenSite

        case .breakageCategorySelected: domainEvent = .reportBrokenSiteBreakageCategorySelected
        case .overallCategorySelected: domainEvent = .reportBrokenSiteOverallCategorySelected
        case .reportBrokenSiteShown: domainEvent = .reportBrokenSiteShown
        case .reportBrokenSiteSent: domainEvent = .reportBrokenSiteSent
        case .skipToggleStep: domainEvent = .reportBrokenSiteSkipToggleStep
        case .toggleProtectionOff: domainEvent = .reportBrokenSiteToggleProtectionOff
        }
        if let parameters {
            Pixel.fire(pixel: domainEvent, withAdditionalParameters: parameters)
        } else {
            Pixel.fire(pixel: domainEvent)
        }
    }

    init?(coder: NSCoder,
          privacyInfo: PrivacyInfo?,
          entryPoint: PrivacyDashboardEntryPoint,
          privacyConfigurationManager: PrivacyConfigurationManaging,
          contentBlockingManager: ContentBlockerRulesManager,
          breakageAdditionalInfo: BreakageAdditionalInfo?) {

        var variant: PrivacyDashboardVariant {
            let isExperimentEnabled = privacyConfigurationManager.privacyConfig.isEnabled(featureKey: .brokenSiteReportExperiment)
            return isExperimentEnabled ? PixelExperiment.privacyDashboardVariant : PrivacyDashboardVariant.control
        }

        let toggleReportingConfiguration = ToggleReportingConfiguration(privacyConfigurationManager: privacyConfigurationManager)
        let toggleReportingFeature = ToggleReportingFeature(toggleReportingConfiguration: toggleReportingConfiguration)
        let toggleReportingManager = ToggleReportingManager(feature: toggleReportingFeature)
        privacyDashboardController = PrivacyDashboardController(privacyInfo: privacyInfo,
                                                                entryPoint: entryPoint,
                                                                variant: variant,
                                                                toggleReportingManager: toggleReportingManager,
                                                                eventMapping: privacyDashboardEvents)
        self.privacyConfigurationManager = privacyConfigurationManager
        self.contentBlockingManager = contentBlockingManager
        self.breakageAdditionalInfo = breakageAdditionalInfo
        super.init(coder: coder)
        
        privacyDashboardController.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        privacyDashboardController.setup(for: webView)
        privacyDashboardController.preferredLocale = Bundle.main.preferredLocalizations.first
        
        decorate()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !privacyDashboardDidTriggerDismiss {
            privacyDashboardController.handleViewWillDisappear()
        }
        privacyDashboardController.cleanup()
    }
    
    public func updatePrivacyInfo(_ privacyInfo: PrivacyInfo?) {
        privacyDashboardController.didFinishRulesCompilation()
        privacyDashboardController.updatePrivacyInfo(privacyInfo)
    }

    private func privacyDashboardProtectionSwitchChangeHandler(state: ProtectionState, didSendReport: Bool = false) {
        privacyDashboardDidTriggerDismiss = true
        guard let domain = privacyDashboardController.privacyInfo?.url.host else { return }
        
        let privacyConfiguration = privacyConfigurationManager.privacyConfig
        let pixelParam = ["trigger_origin": state.eventOrigin.screen.rawValue,
                          "source": privacyDashboardController.source.rawValue]
        if state.isProtected {
            privacyConfiguration.userEnabledProtection(forDomain: domain)
            ActionMessageView.present(message: UserText.messageProtectionEnabled.format(arguments: domain))
            Pixel.fire(pixel: .dashboardProtectionAllowlistRemove, withAdditionalParameters: pixelParam)
        } else {
            privacyConfiguration.userDisabledProtection(forDomain: domain)
            if didSendReport {
                ActionMessageView.present(message: UserText.messageProtectionDisabledAndToggleReportSent.format(arguments: domain))
            } else {
                ActionMessageView.present(message: UserText.messageProtectionDisabled.format(arguments: domain))
            }
            Pixel.fire(pixel: .dashboardProtectionAllowlistAdd, withAdditionalParameters: pixelParam)
        }
        
        contentBlockingManager.scheduleCompilation()
    }
    
    private func privacyDashboardCloseHandler() {
        privacyDashboardDidTriggerDismiss = true
        dismiss(animated: true)
    }
}

extension PrivacyDashboardViewController {
    
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme
        view.backgroundColor = theme.privacyDashboardWebviewBackgroundColor
        privacyDashboardController.theme = .init(theme)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            privacyDashboardController.theme = .init()
        }
    }
}

// MARK: - PrivacyDashboardControllerDelegate

extension PrivacyDashboardViewController: PrivacyDashboardControllerDelegate {
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didSelectBreakageCategory category: String) {
        delegate?.privacyDashboardViewController(self, didSelectBreakageCategory: category)
    }

    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    didChangeProtectionSwitch protectionState: ProtectionState,
                                    didSendReport: Bool) {
        privacyDashboardProtectionSwitchChangeHandler(state: protectionState, didSendReport: didSendReport)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didRequestOpenUrlInNewTab url: URL) {
        guard let mainViewController = presentingViewController as? MainViewController else { return }
        dismiss(animated: true) {
            mainViewController.loadUrlInNewTab(url, inheritedAttribution: nil)
        }
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    didRequestOpenSettings target: PrivacyDashboardOpenSettingsTarget) {
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
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, didSetHeight height: Int) {
        // The size received in iPad is wrong, shane will sort this out soon.
        // preferredContentSize.height = CGFloat(height)
    }
    
    func privacyDashboardControllerDidRequestClose(_ privacyDashboardController: PrivacyDashboardController) {
        privacyDashboardCloseHandler()
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    reportBrokenSiteDidChangeProtectionSwitch protectionState: ProtectionState) {
        privacyDashboardProtectionSwitchChangeHandler(state: protectionState)
    }
    
    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    didRequestSubmitBrokenSiteReportWithCategory category: String,
                                    description: String) {
        Task { @MainActor in
            do {
                let report = try await makeBrokenSiteReport(category: category, description: description, source: privacyDashboardController.source)
                try brokenSiteReporter.report(report, reportMode: .regular)
            } catch {
                os_log("Failed to generate or send the broken site report: %@", type: .error, error.localizedDescription)
            }
            let message = PixelExperiment.cohort == .control ? UserText.feedbackSumbittedConfirmation : UserText.brokenSiteReportSuccessToast
            ActionMessageView.present(message: message)
            privacyDashboardCloseHandler()
        }
    }

    func privacyDashboardControllerDidRequestShowGeneralFeedback(_ privacyDashboardController: PrivacyDashboardController) {
        guard let mainViewController = presentingViewController as? MainViewController else { return }
        dismiss(animated: true) {
            mainViewController.segueToNegativeFeedbackForm(isFromBrokenSiteReportFlow: true)
        }
    }

    func privacyDashboardControllerDidRequestShowAlertForMissingDescription(_ privacyDashboardController: PrivacyDashboardController) {
        let alert = UIAlertController(title: UserText.brokenSiteReportMissingDescriptionAlertTitle,
                                      message: UserText.brokenSiteReportMissingDescriptionAlertDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UserText.brokenSiteReportMissingDescriptionAlertButton, style: .default))
        present(alert, animated: true)
    }

    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController,
                                    didRequestSubmitToggleReportWithSource source: BrokenSiteReport.Source) {
        Task { @MainActor in
            do {
                let report = try await makeBrokenSiteReport(source: source)
                try toggleProtectionsOffReporter.report(report, reportMode: .toggle)
            } catch {
                os_log("Failed to generate or send the broken site report: %@", type: .error, error.localizedDescription)
            }

            privacyDashboardCloseHandler()
        }
    }

    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, 
                                    didSetPermission permissionName: String,
                                    to state: PermissionAuthorizationState) {
        // not supported on iOS
    }

    func privacyDashboardController(_ privacyDashboardController: PrivacyDashboardController, setPermission permissionName: String, paused: Bool) {
        // not supported on iOS
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
        let openerContext: BrokenSiteReport.OpenerContext?
        let vpnOn: Bool
        let userRefreshCount: Int
        let performanceMetrics: PerformanceMetricsSubfeature?
    }
    
    enum BrokenSiteReportError: Error {
        case failedToFetchTheCurrentWebsiteInfo
    }

    private func calculateWebVitals(breakageAdditionalInfo: BreakageAdditionalInfo, privacyConfig: PrivacyConfiguration) async -> [Double]? {
        var webVitalsResult: [Double]?
        if privacyConfig.isEnabled(featureKey: .performanceMetrics) {
            webVitalsResult = await withCheckedContinuation({ continuation in
                guard let performanceMetrics = breakageAdditionalInfo.performanceMetrics else { continuation.resume(returning: nil); return }
                performanceMetrics.notifyHandler { result in
                    continuation.resume(returning: result)
                }
            })
        }

        return webVitalsResult
    }

    private func makeBrokenSiteReport(category: String = "",
                                      description: String = "",
                                      source: BrokenSiteReport.Source) async throws -> BrokenSiteReport {

        guard let privacyInfo = privacyDashboardController.privacyInfo,
              let breakageAdditionalInfo = breakageAdditionalInfo  else {
            throw BrokenSiteReportError.failedToFetchTheCurrentWebsiteInfo
        }

        let webVitalsResult = await calculateWebVitals(breakageAdditionalInfo: breakageAdditionalInfo,
                                                       privacyConfig: privacyConfigurationManager.privacyConfig)

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
                                httpStatusCodes: statusCodes,
                                openerContext: breakageAdditionalInfo.openerContext,
                                vpnOn: breakageAdditionalInfo.vpnOn,
                                jsPerformance: webVitalsResult,
                                userRefreshCount: breakageAdditionalInfo.userRefreshCount,
                                variant: PixelExperiment.cohort?.rawValue ?? "")
    }

}

private extension PrivacyDashboardTheme {
    init(_ userInterfaceStyle: UIUserInterfaceStyle = ThemeManager.shared.currentInterfaceStyle) {
        switch userInterfaceStyle {
        case .light: self = .light
        case .dark: self = .dark
        case .unspecified: self = .light
        @unknown default: self = .light
        }
    }

    init(_ theme: Theme) {
        switch theme.name {
        case .light: self = .light
        case .dark: self = .dark
        case .systemDefault: self.init(ThemeManager.shared.currentInterfaceStyle)
        }
    }
}
