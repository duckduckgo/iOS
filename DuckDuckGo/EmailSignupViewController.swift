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
import SecureStorage

// swiftlint:disable file_length
class EmailSignupViewController: UIViewController {

    private enum Constants {
        static let duckDuckGoTitle: String = "DuckDuckGo"
        static let backImage = UIImage(systemName: "chevron.left")

        static let emailPath: String = "email/"
        static let emailStartInContextPath: String = "email/start-incontext"
        static let emailChooseAddressPath: String = "email/choose-address"
        static let emailReviewPath: String = "email/review"
        static let emailWelcomePath: String = "email/welcome"
        static let emailWelcomeInContextPath: String = "email/welcome-incontext"
    }

    private enum SignupState {
        case start
        case emailEntered
        case complete
        case other
    }

    let completion: ((Bool) -> Void)

    private var webView: WKWebView!

    private var webViewUrlObserver: NSKeyValueObservation?

    lazy private var featureFlagger = AppDependencyProvider.shared.featureFlagger

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

    private var url: URL? {
        didSet {
            guard let url = url else {
                navigationItem.rightBarButtonItems = []
                return
            }
            if url.absoluteString.hasSuffix(Constants.emailPath) || url.absoluteString.hasSuffix(Constants.emailStartInContextPath) {
                signupStage = .start
            } else if url.absoluteString.hasSuffix(Constants.emailChooseAddressPath) || url.absoluteString.hasSuffix(Constants.emailReviewPath) {
                signupStage = .emailEntered
            } else if url.absoluteString.hasSuffix(Constants.emailWelcomePath) || url.absoluteString.hasSuffix(Constants.emailWelcomeInContextPath) {
                signupStage = .complete
            } else {
                signupStage = .other
            }
        }
    }

    @Published private var signupStage: SignupState = .start {
        didSet {
            updateNavigationBarButtons()
        }
    }

    private var canGoBack: Bool {
        let webViewCanGoBack = webView.canGoBack
        let navigatedToError = webView.url != nil
        return webViewCanGoBack || navigatedToError
    }

    private lazy var backBarButtonItem: UIBarButtonItem = {
        let button = UIButton(type: .system)
        button.setImage(Constants.backImage, for: .normal)
        button.setTitle(UserText.backButtonTitle, for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()

    private lazy var cancelBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
    }()

    private lazy var nextBarButtonItem: UIBarButtonItem = {
        UIBarButtonItem(title: UserText.navigationTitleDone,
                        style: .plain,
                        target: self,
                        action: #selector(nextButtonPressed))
    }()

    // MARK: - Public interface

    init(completion: @escaping ((Bool) -> Void)) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupNavigationBarTitle()
        addDuckDuckGoEmailObserver()
        applyTheme(ThemeManager.shared.currentTheme)

        isModalInPresentation = true
        navigationController?.presentationController?.delegate = self

        Pixel.fire(pixel: .emailIncontextModalDisplayed)
    }


    func loadUrl(_ url: URL?) {
        guard let url = url else { return }

        let request = URLRequest.userInitiated(url)
        webView.load(request)
    }


    // MARK: - Private

    private func setupWebView() {
        let configuration =  WKWebViewConfiguration.persistent()
        let userContentController = UserContentController()
        configuration.userContentController = userContentController
        userContentController.delegate = self

        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        view.addSubview(webView)

        webViewUrlObserver = webView.observe(\.url, options: .new, changeHandler: { [weak self] _, _ in
            self?.webViewUrlHasChanged()
        })

        if #available(iOS 16.4, *) {
            updateWebViewInspectability()
        }

        // Slight delay needed for userScripts to load otherwise email protection webpage reports that this is an unsupported browser
        let workItem = DispatchWorkItem { [unowned self] in
            self.loadUrl(URL.emailProtectionSignUp)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }

    @available(iOS 16.4, *) @objc
    private func updateWebViewInspectability() {
#if DEBUG
        webView.isInspectable = true
#else
        webView.isInspectable = AppUserDefaults().inspectableWebViewEnabled
#endif
    }

    private func webViewUrlHasChanged() {
        url = webView.url
    }

    private func setupNavigationBarTitle() {
        let titleLabel: UILabel = UILabel()
        titleLabel.text = Constants.duckDuckGoTitle
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
    private func backButtonPressed() {
        if canGoBack {
            webView.goBack()
        }
    }

    @objc
    private func cancelButtonPressed() {
        Pixel.fire(pixel: .emailIncontextModalDismissed)
        completed(false)
    }

    @objc
    private func nextButtonPressed() {
        emailSignupCompleted()
    }

    private func emailSignupCompleted() {
        completed(true)
    }

    private func completed(_ success: Bool) {
        completion(success)
        dismiss(animated: true)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension EmailSignupViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

}

// MARK: - UIAdaptivePresentationControllerDelegate

extension EmailSignupViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        if case .emailEntered = signupStage {
            let alert = UIAlertController(title: UserText.emailSignupExitEarlyAlertTitle, message: nil, preferredStyle: .alert)

            let continueAction = UIAlertAction(title: UserText.emailSignupExitEarlyActionContinue, style: .default) { _ in
                Pixel.fire(pixel: .emailIncontextModalExitEarlyContinue)
            }

            let cancelAction = UIAlertAction(title: UserText.emailSignupExitEarlyActionExit, style: .default) { [weak self] _ in
                Pixel.fire(pixel: .emailIncontextModalExitEarly)
                self?.completed(false)
            }

            alert.addAction(continueAction)
            alert.addAction(cancelAction)
            alert.preferredAction = continueAction

            present(alert, animated: true)
        } else if case .complete = signupStage {
            completed(true)
        } else {
            Pixel.fire(pixel: .emailIncontextModalDismissed)
            completed(false)
        }
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

// MARK: - EmailManagerRequestDelegate

extension EmailSignupViewController: EmailManagerRequestDelegate {

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

}

// MARK: - SecureVaultManagerDelegate

extension EmailSignupViewController: SecureVaultManagerDelegate {

    func secureVaultInitFailed(_ error: SecureStorageError) {
        SecureVaultErrorReporter.shared.secureVaultInitFailed(error)
    }

    func secureVaultManagerIsEnabledStatus(_ manager: SecureVaultManager, forType type: AutofillType?) -> Bool {
        let isEnabled = AutofillSettingStatus.isAutofillEnabledInSettings && featureFlagger.isFeatureOn(.autofillCredentialInjecting)
        return isEnabled
    }

    func secureVaultManagerShouldSaveData(_: BrowserServicesKit.SecureVaultManager) -> Bool {
        return false
    }

    func secureVaultManager(_ vault: SecureVaultManager,
                            promptUserToStoreAutofillData data: AutofillData,
                            withTrigger trigger: AutofillUserScript.GetTriggerType?) {
        // no-op
    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserToAutofillCredentialsForDomain domain: String,
                            withAccounts accounts: [SecureVaultModels.WebsiteAccount],
                            withTrigger trigger: AutofillUserScript.GetTriggerType,
                            completionHandler: @escaping (SecureVaultModels.WebsiteAccount?) -> Void) {
        // no-op
    }

    func secureVaultManager(_: SecureVaultManager,
                            promptUserWithGeneratedPassword password: String,
                            completionHandler: @escaping (Bool) -> Void) {
        // no-op
    }
    
    // Used on macOS to request authentication for individual autofill items
    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager,
                            isAuthenticatedFor type: BrowserServicesKit.AutofillType,
                            completionHandler: @escaping (Bool) -> Void) {
        completionHandler(true)
    }

    func secureVaultManager(_: SecureVaultManager, didAutofill type: AutofillType, withObjectId objectId: String) {
        // no-op
    }

    func secureVaultManager(_: SecureVaultManager, didRequestAuthenticationWithCompletionHandler: @escaping (Bool) -> Void) {
        // no-op
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestCreditCardsManagerForDomain domain: String) {
        // no-op
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestIdentitiesManagerForDomain domain: String) {
        // no-op
    }

    func secureVaultManager(_: BrowserServicesKit.SecureVaultManager, didRequestPasswordManagerForDomain domain: String) {
        // no-op
    }

    func secureVaultManager(_: SecureVaultManager, didRequestRuntimeConfigurationForDomain domain: String, completionHandler: @escaping (String?) -> Void) {
        completionHandler(nil)
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
