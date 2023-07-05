//
//  EmailSignupViewController.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import BrowserServicesKit
import Common
import Core
import Networking
import UserScript
import WebKit

protocol EmailSignupViewControllerDelegate: AnyObject {
    func emailSignupViewControllerDidFinish(_ controller: EmailSignupViewController)
}

// swiftlint:disable file_length
class EmailSignupViewController: UIViewController {

    private enum Constants {
//        static let signUpUrl: String = "https://quackdev.com/email/start-incontext"
        static let signUpUrl: String = "https://duckduckgo.com/email/start-incontext"
    }

    private(set) var webView: WKWebView!
    private var webViewContainer: UIView

    weak var delegate: EmailSignupViewControllerDelegate?

    lazy private var emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.aliasPermissionDelegate = self
        emailManager.requestDelegate = self
        return emailManager
    }()

    lazy private var vaultManager: SecureVaultManager = {
        let manager = SecureVaultManager(includePartialAccountMatches: true,
                                         tld: AppDependencyProvider.shared.storageCache.tld)
        manager.delegate = self
        return manager
    }()

    private lazy var nextBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: "Next",
                        style: .plain,
                        target: self,
                        action: #selector(nextButtonPressed))
    }()

    private var url: URL? {
        didSet {
            if let url = url, url.absoluteString.contains("welcome") || url.absoluteString.contains("settings") {
                navigationItem.rightBarButtonItems = [nextBarButtonItem]
            } else {
                navigationItem.rightBarButtonItems = []
            }
        }
    }

    init() {
        self.webViewContainer = UIView()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 16.4, *) {
            registerForInspectableWebViewNotifications()
        }

        setup()
    }

    private func setup() {
        view.addSubview(webViewContainer)

        webViewContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webViewContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            webViewContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            webViewContainer.topAnchor.constraint(equalTo: view.topAnchor),
            webViewContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])


        let configuration =  WKWebViewConfiguration.persistent()

        let request = URLRequest.userInitiated(URL(string: Constants.signUpUrl)!)
        attachWebView(configuration: configuration, andLoadRequest: request, consumeCookies: true)
    }


    private func attachWebView(configuration: WKWebViewConfiguration,
                               andLoadRequest request: URLRequest?,
                               consumeCookies: Bool,
                               loadingInitiatedByParentTab: Bool = false) {

        let userContentController = UserContentController()
        configuration.userContentController = userContentController
        userContentController.delegate = self

        webView = WKWebView(frame: webViewContainer.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addObservers()

        webViewContainer.addSubview(webView)


        if #available(iOS 16.4, *) {
            updateWebViewInspectability()
        }

        let assertion = DispatchWorkItem { [unowned self] in
            consumeCookiesThenLoadRequest(request)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: assertion)
    }

    @available(iOS 16.4, *)
    private func registerForInspectableWebViewNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateWebViewInspectability),
                                               name: AppUserDefaults.Notifications.inspectableWebViewsToggled,
                                               object: nil)
    }

    @available(iOS 16.4, *) @objc
    private func updateWebViewInspectability() {
#if DEBUG
        webView.isInspectable = true
#else
        webView.isInspectable = AppUserDefaults().inspectableWebViewEnabled
#endif
    }

    private func consumeCookiesThenLoadRequest(_ request: URLRequest?) {
        webView.configuration.websiteDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { _ in
            WebCacheManager.shared.consumeCookies { [weak self] in
                guard let strongSelf = self else { return }

                if let request = request {
                    strongSelf.load(urlRequest: request)
                }
            }
        }
    }

    private func load(urlRequest: URLRequest) {
        loadViewIfNeeded()

        if #available(iOS 15.0, *) {
            assert(urlRequest.attribution == .user, "WebView requests should be user attributed")
        }

        webView.stopLoading()
        webView.load(urlRequest)
    }

    private func addObservers() {
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.url), options: .new, context: nil)
    }

    // swiftlint:disable block_based_kvo
    open override func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey: Any]?,
                                    context: UnsafeMutableRawPointer?) {
        // swiftlint:enable block_based_kvo

        guard let keyPath = keyPath else { return }

        switch keyPath {

        case #keyPath(WKWebView.url):
            webViewUrlHasChanged()

        default:
            os_log("Unhandled keyPath %s", log: .generalLog, type: .debug, keyPath)
        }
    }

    private func webViewUrlHasChanged() {
        print("webViewUrlHasChanged: \(String(describing: webView.url))")
        url = webView.url
    }

    @objc
    func nextButtonPressed() {
        delegate?.emailSignupViewControllerDidFinish(self)
        dismiss(animated: true)
    }


}

// MARK: - EmailManagerAliasPermissionDelegate
extension EmailSignupViewController: EmailManagerAliasPermissionDelegate {

    func emailManager(_ emailManager: EmailManager,
                      didRequestPermissionToProvideAliasWithCompletion completionHandler: @escaping (EmailManagerPermittedAddressType) -> Void) {

        DispatchQueue.main.async {
            let alert = UIAlertController(title: UserText.emailAliasAlertTitle, message: nil, preferredStyle: .actionSheet)
            alert.overrideUserInterfaceStyle()

            var pixelParameters: [String: String] = [:]

            if let cohort = emailManager.cohort {
                pixelParameters[PixelParameters.emailCohort] = cohort
            }

            if let userEmail = emailManager.userEmail {
                let actionTitle = String(format: UserText.emailAliasAlertUseUserAddress, userEmail)
                alert.addAction(title: actionTitle) {
                    pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
                    emailManager.updateLastUseDate()

                    Pixel.fire(pixel: .emailUserPressedUseAddress, withAdditionalParameters: pixelParameters, includedParameters: [])

                    completionHandler(.user)
                }
            }

            alert.addAction(title: UserText.emailAliasAlertGeneratePrivateAddress) {
                pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
                emailManager.updateLastUseDate()

                Pixel.fire(pixel: .emailUserPressedUseAlias, withAdditionalParameters: pixelParameters, includedParameters: [])

                completionHandler(.generated)
            }

            alert.addAction(title: UserText.emailAliasAlertDecline) {
                Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters, includedParameters: [])

                completionHandler(.none)
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                // make sure the completion handler is called if the alert is dismissed by tapping outside the alert
                alert.addAction(title: "", style: .cancel) {
                    Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters)
                    completionHandler(.none)
                }
            }

            alert.popoverPresentationController?.permittedArrowDirections = []
            alert.popoverPresentationController?.delegate = self
            let bounds = self.view.bounds
            let point = Point(x: Int((bounds.maxX - bounds.minX) / 2.0), y: Int(bounds.maxY))
            self.present(controller: alert, fromView: self.view, atPoint: point)
        }

    }

}

// MARK: - EmailManagerRequestDelegate
extension EmailSignupViewController: EmailManagerRequestDelegate {
    func emailManagerIncontextPromotion() {
        // no-op
    }


    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager, requested url: URL, method: String, headers: [String: String], parameters: [String: String]?, httpBody: Data?, timeoutInterval: TimeInterval) async throws -> Data {
        let method = APIRequest.HTTPMethod(rawValue: method) ?? .post
        let configuration = APIRequest.Configuration(url: url,
                                                     method: method,
                                                     queryParameters: parameters ?? [:],
                                                     headers: headers,
                                                     body: httpBody,
                                                     timeoutInterval: timeoutInterval)
        let request = APIRequest(configuration: configuration, urlSession: .session())
        return try await request.fetch().data ?? { throw AliasRequestError.noDataError }()
    }
    // swiftlint:enable function_parameter_count

    func emailManagerKeychainAccessFailed(accessType: EmailKeychainAccessType, error: EmailKeychainAccessError) {
        var parameters = [
            PixelParameters.emailKeychainAccessType: accessType.rawValue,
            PixelParameters.emailKeychainError: error.errorDescription
        ]

        if case let .keychainLookupFailure(status) = error {
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "lookup"
        }

        if case let .keychainDeleteFailure(status) = error {
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "delete"
        }

        if case let .keychainSaveFailure(status) = error {
            parameters[PixelParameters.emailKeychainKeychainStatus] = String(status)
            parameters[PixelParameters.emailKeychainKeychainOperation] = "save"
        }

        Pixel.fire(pixel: .emailAutofillKeychainError, withAdditionalParameters: parameters)
    }


}

// MARK: - UIPopoverPresentationControllerDelegate
extension EmailSignupViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

// MARK: - UserContentControllerDelegate
extension EmailSignupViewController: UserContentControllerDelegate {

    func userContentController(_ userContentController: UserContentController,
                               didInstallContentRuleLists contentRuleLists: [String: WKContentRuleList],
                               userScripts: UserScriptsProvider,
                               updateEvent: ContentBlockerRulesManager.UpdateEvent) {
        guard let userScripts = userScripts as? UserScripts else { fatalError("Unexpected UserScripts") }

        userScripts.autofillUserScript.emailDelegate = emailManager
        userScripts.autofillUserScript.vaultDelegate = vaultManager
    }

}

extension EmailSignupViewController: SecureVaultManagerDelegate {


    func secureVaultInitFailed(_ error: SecureVaultError) {
        SecureVaultErrorReporter.shared.secureVaultInitFailed(error)
    }

    func secureVaultManagerIsEnabledStatus(_: SecureVaultManager) -> Bool {
//        let isEnabled = AutofillSettingStatus.isAutofillEnabledInSettings && featureFlagger.isFeatureOn(.autofillCredentialInjecting)
//        let isBackgrounded = UIApplication.shared.applicationState == .background
//        if isEnabled && isBackgrounded {
//            Pixel.fire(pixel: .secureVaultIsEnabledCheckedWhenEnabledAndBackgrounded,
//                       withAdditionalParameters: [PixelParameters.isBackgrounded: "true"])
//        }
        return true
    }

    func secureVaultManager(_ vault: SecureVaultManager,
                            promptUserToStoreAutofillData data: AutofillData,
                            hasGeneratedPassword generatedPassword: Bool,
                            withTrigger trigger: AutofillUserScript.GetTriggerType?) {

    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserToAutofillCredentialsForDomain domain: String,
                            withAccounts accounts: [SecureVaultModels.WebsiteAccount],
                            withTrigger trigger: AutofillUserScript.GetTriggerType,
                            completionHandler: @escaping (SecureVaultModels.WebsiteAccount?) -> Void) {
        completionHandler(nil)
    }

    func secureVaultManager(_: SecureVaultManager, didAutofill type: AutofillType, withObjectId objectId: String) {
        // No-op, don't need to do anything here
    }

    func secureVaultManagerShouldAutomaticallyUpdateCredentialsWithoutUsername(_: SecureVaultManager, shouldSilentlySave: Bool) -> Bool {
        return false
    }

    func secureVaultManagerShouldSilentlySaveGeneratedPassword(_: SecureVaultManager) -> Bool {
        return false
    }

    func secureVaultManager(_: SecureVaultManager, didRequestAuthenticationWithCompletionHandler: @escaping (Bool) -> Void) {
        // We don't have auth yet
    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserWithGeneratedPassword password: String,
                            completionHandler: @escaping (Bool) -> Void) {
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestCreditCardsManagerForDomain domain: String) {
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestIdentitiesManagerForDomain domain: String) {
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestPasswordManagerForDomain domain: String) {
    }

    func secureVaultManager(_: SecureVaultManager, didReceivePixel pixel: AutofillUserScript.JSPixel) {
        guard !pixel.isEmailPixel else {
            // The iOS app uses a native email autofill UI, and sends its pixels separately. Ignore pixels sent from the JS layer.
            return
        }

        Pixel.fire(pixel: .autofillJSPixelFired(pixel))
    }

}
// swiftlint:enable file_length
