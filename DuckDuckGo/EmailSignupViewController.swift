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
import DesignResourcesKit

protocol EmailSignupViewControllerDelegate: AnyObject {
    func emailSignupViewControllerDidFinish(_ controller: EmailSignupViewController, completionHandler: @escaping () -> Void)
}

// swiftlint:disable file_length
class EmailSignupViewController: UIViewController {

    private enum Constants {
//        static let signUpUrl: String = "https://quack.duckduckgo.com/email/start-incontext"
        static let signUpUrl: String = "https://duckduckgo.com/email/start-incontext"
    }

    weak var delegate: EmailSignupViewControllerDelegate?

    let completion: ((Bool) -> Void)

    private var webView: WKWebView!

    private var canGoBack: Bool {
        let webViewCanGoBack = webView.canGoBack
        let navigatedToError = webView.url != nil
        return webViewCanGoBack || navigatedToError
    }

    lazy var featureFlagger = AppDependencyProvider.shared.featureFlagger

    lazy private var emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.requestDelegate = self
        return emailManager
    }()

    lazy private var vaultManager: SecureVaultManager = {
        let manager = SecureVaultManager(includePartialAccountMatches: true,
                                         tld: AppDependencyProvider.shared.storageCache.tld)
        manager.delegate = self
        return manager
    }()

    private lazy var backBarButtonItem: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.setTitle(UserText.backButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()

    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
    }()

    private lazy var nextBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: UserText.nextButtonTitle,
                        style: .plain,
                        target: self,
                        action: #selector(nextButtonPressed))
    }()

    private var url: URL? {
        didSet {
            guard let url = url else {
                navigationItem.rightBarButtonItems = []
                return
            }
            if url.absoluteString.contains("welcome") {
                navigationItem.leftBarButtonItems = []
                navigationItem.rightBarButtonItem = nextBarButtonItem
            } else if url.absoluteString.hasSuffix("email/") {
                navigationItem.leftBarButtonItem = cancelBarButtonItem
                navigationItem.rightBarButtonItems = []
            } else if url.absoluteString.contains("start-incontext") {
                navigationItem.leftBarButtonItems = []
                navigationItem.rightBarButtonItems = []
            } else {
                navigationItem.leftBarButtonItems = canGoBack ? [backBarButtonItem] : []
                navigationItem.rightBarButtonItems = []
            }
        }
    }

    init(completion: @escaping ((Bool) -> Void)) {
        self.completion = completion
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
        navBarTitle()
        addDuckDuckGoEmailObserver()
        applyTheme(ThemeManager.shared.currentTheme)
    }

    private func navBarTitle() {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "DuckDuckGo"
        titleLabel.font = .daxFootnoteRegular()
        titleLabel.textColor = UIColor(designSystemColor: .textSecondary)

        let subtitleLabel: UILabel = UILabel()
        subtitleLabel.text = "Email Protection"
        subtitleLabel.font = .daxHeadline()
        subtitleLabel.textColor = UIColor(designSystemColor: .textPrimary)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center

        navigationItem.titleView = stackView
    }

    private func setup() {
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

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(webView)

        if #available(iOS 16.4, *) {
            updateWebViewInspectability()
        }

        let assertion = DispatchWorkItem { [unowned self] in
            if let request = request {
                webView.load(request)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: assertion)

        addObservers()

    }

    private func addDuckDuckGoEmailObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDuckDuckGoEmailDidCloseEmailProtection),
                                               name: .emailDidCloseEmailProtection,
                                               object: nil)
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

    private func setupNavigationBarTitle() {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = "DuckDuckGo"
        titleLabel.font = .daxFootnoteRegular()
        titleLabel.textColor = UIColor(designSystemColor: .textSecondary)

        let subtitleLabel: UILabel = UILabel()
        subtitleLabel.text = UserText.emailProtection
        subtitleLabel.font = .daxHeadline()
        subtitleLabel.textColor = UIColor(designSystemColor: .textPrimary)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center

        navigationItem.titleView = stackView
    }

    private func addDuckDuckGoEmailObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDuckDuckGoEmailSignIn),
                                               name: .emailDidSignIn,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onDuckDuckGoEmailDidCloseEmailProtection),
                                               name: .emailDidCloseEmailProtection,
                                               object: nil)
    }

    @objc
    private func onDuckDuckGoEmailSignIn(_ notification: Notification) {
        if signupStage != .complete {
            // TODO - pixel
            completed(true)
        }
    }

    @objc
    private func onDuckDuckGoEmailDidCloseEmailProtection(_ notification: Notification) {
        emailSignupCompleted()
    }

    private func updateNavigationBarButtons() {
        switch signupStage {
        case .start:
            navigationItem.leftBarButtonItem = cancelBarButtonItem
            navigationItem.rightBarButtonItem = nil
        case .complete:
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nextBarButtonItem
        default:
            navigationItem.leftBarButtonItem = canGoBack ? backBarButtonItem : nil
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc
    func backButtonPressed() {
        if canGoBack {
            webView.goBack()
        }
    }

    @objc
    func cancelButtonPressed() {
        // TODO - pixel
        dismiss(animated: true)
    }

    @objc
    func nextButtonPressed() {
        emailSignupCompleted()
    }

    @objc
    private func onDuckDuckGoEmailDidCloseEmailProtection(_ notification: Notification) {
        emailSignupCompleted()
    }

    func emailSignupCompleted() {
        delegate?.emailSignupViewControllerDidFinish(self, completionHandler: completionHandler!)
        dismiss(animated: true)
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
                                                     headers: APIRequest.Headers(additionalHeaders: headers),
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
        let isEnabled = AutofillSettingStatus.isAutofillEnabledInSettings && featureFlagger.isFeatureOn(.autofillCredentialInjecting)
        let isBackgrounded = UIApplication.shared.applicationState == .background
        if isEnabled && isBackgrounded {
            Pixel.fire(pixel: .secureVaultIsEnabledCheckedWhenEnabledAndBackgrounded,
                       withAdditionalParameters: [PixelParameters.isBackgrounded: "true"])
        }
        return isEnabled
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

// MARK: Themable

extension EmailSignupViewController: Themable {
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor

        navigationController?.navigationBar.barTintColor = theme.barBackgroundColor
        navigationController?.navigationBar.tintColor = theme.navigationBarTintColor
    }
}

// swiftlint:enable file_length
