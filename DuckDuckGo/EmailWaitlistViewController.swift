//
//  EmailWaitlistViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import UserNotifications

class EmailWaitlistViewController: UIViewController {

    private enum Constants {
        static var contactUsImage = UIImage(named: "EmailWaitlistContactUs")!
        static var weHatchedImage = UIImage(named: "EmailWaitlistWeHatched")!
    }

    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var headerDescriptionTextView: UITextView! {
        didSet {
            headerDescriptionTextView.linkTextAttributes = textViewLinkAttributes()
        }
    }

    @IBOutlet weak var footerTextView: UITextView! {
        didSet {
            footerTextView.linkTextAttributes = textViewLinkAttributes()
        }
    }

    @IBOutlet weak var waitlistActionButton: UIButton! {
        didSet {
            applyWaitlistButtonStyle(to: waitlistActionButton, hasSolidBackground: true)
        }
    }

    @IBOutlet weak var existingInviteCodeButton: UIButton! {
        didSet {
            applyWaitlistButtonStyle(to: existingInviteCodeButton)
        }
    }

    @IBOutlet weak var existingDuckAddressButton: UIButton! {
        didSet {
            applyWaitlistButtonStyle(to: existingDuckAddressButton)
        }
    }

    lazy var emailManager: EmailManager = {
        let emailManager = EmailManager()
        emailManager.requestDelegate = self
        return emailManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme(ThemeManager.shared.currentTheme)
        renderCurrentWaitlistState()
    }

    @IBAction func waitlistActionButtonTapped(_ sender: UIButton) {
        switch emailManager.waitlistState {
        case .notJoinedQueue: joinWaitlist()
        case .inBeta: getStarted()
        case .joinedQueue:
            assertionFailure("\(#file): No action for .joinedQueue")
            return
        }
    }

    @IBAction func existingInviteCodeButtonTapped(_ sender: UIButton) {
        showEmailWaitlistWebViewController(url: AppUrls().signUpQuickLink)
    }

    @IBAction func existingDuckAddressButtonTapped(_ sender: UIButton) {
        showEmailWaitlistWebViewController(url: AppUrls().emailLoginQuickLink)
    }

    // MARK: - Private

    private func textViewLinkAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16

        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: 16,
            NSAttributedString.Key.foregroundColor: UIColor.emailWaitlistLinkColor
        ]

        return linkAttributes
    }

    private func applyWaitlistButtonStyle(to button: UIButton, hasSolidBackground: Bool = false) {
        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.borderWidth = 2.0
        button.layer.borderColor = UIColor.emailWaitlistLinkColor.cgColor

        if hasSolidBackground {
            button.layer.backgroundColor = UIColor.emailWaitlistLinkColor.cgColor
        }
    }

    private func renderCurrentWaitlistState() {
        render(waitlistState: emailManager.waitlistState)
    }

    private func render(waitlistState: EmailManagerWaitlistState) {
        switch waitlistState {
        case .notJoinedQueue: renderNotJoinedQueueState()
        case .joinedQueue: renderJoinedQueueState()
        case .inBeta: renderInBetaState()
        }
    }

    private func renderNotJoinedQueueState() {
        headerImageView.image = Constants.contactUsImage

        headerTitleLabel.text = UserText.emailWaitlistPrivacySimplified
        headerDescriptionTextView.attributedText = createAttributedWaitlistSummary()
        footerTextView.attributedText = createAttributedPrivacyGuaranteeString()

        waitlistActionButton.isEnabled = true
        waitlistActionButton.isHidden = false
        waitlistActionButton.setTitle(UserText.emailWaitlistJoinWaitlist, for: .normal)

        existingInviteCodeButton.isHidden = false
        existingInviteCodeButton.setTitle(UserText.emailWaitlistHaveInviteCode, for: .normal)
    }

    private func renderJoinedQueueState() {
        headerImageView.image = Constants.weHatchedImage

        headerTitleLabel.text = UserText.emailWaitlistJoinedWaitlist

        if EmailWaitlist.shared.showWaitlistNotification {
            headerDescriptionTextView.attributedText = createAttributedWaitlistJoinedWithNotificationSummary()
        } else {
            headerDescriptionTextView.attributedText = createAttributedWaitlistJoinedWithNotificationSummary()
        }

        footerTextView.attributedText = createAttributedPrivacyGuaranteeString()

        waitlistActionButton.isHidden = true
        existingInviteCodeButton.isHidden = false
    }

    private func renderInBetaState() {
        headerImageView.image = Constants.contactUsImage

        headerTitleLabel.text = UserText.emailWaitlistInvited
        headerDescriptionTextView.attributedText = createAttributedWaitlistInvitedSummary()
        footerTextView.attributedText = createAttributedPrivacyGuaranteeString()

        waitlistActionButton.isEnabled = true
        waitlistActionButton.isHidden = false
        waitlistActionButton.setTitle(UserText.emailWaitlistGetStarted, for: .normal)

        existingInviteCodeButton.isHidden = true
    }

    private func joinWaitlist() {
        waitlistActionButton.isEnabled = false
        emailManager.joinWaitlist { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                // When joining the waitlist, the user will be asked whether they want to receive a notification when their invitation is ready.
                self.renderCurrentWaitlistState()
                self.promptForNotificationPermissions()
            case .failure(let error):
                print("Got error: \(error)")
            }
        }
    }

    private func promptForNotificationPermissions() {
        let alertController = UIAlertController(title: UserText.emailWaitlistNotificationPermissionTitle,
                                                message: UserText.emailWaitlistNotificationPermissionBody,
                                                preferredStyle: .alert)

        alertController.addAction(title: UserText.emailWaitlistNotificationPermissionNoThanks, style: .cancel)

        alertController.addAction(title: UserText.emailWaitlistNotificationPermissionNotifyMe, style: .default, handler: {
            EmailWaitlist.shared.showWaitlistNotification = true
            self.showNotificationPermissionAlert()
        })

        present(alertController, animated: true)
    }

    private func showNotificationPermissionAlert() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            guard error != nil else {
                return
            }

            if granted {
                // The task handler will already registered in didFinishLaunching. The background task is checked & scheduled on didBecomeActive, but
                // it should be scheduled after receiving notification permission here to be safe.
                EmailWaitlist.shared.scheduleBackgroundRefreshTask()
            }
        }
    }

    private func getStarted() {
        guard let code = emailManager.inviteCode else {
            assertionFailure("\(#file): Tried to get started but no invite code was present")
            return
        }

        let signUpURL = AppUrls().signUpWithCodeQuickLink(code: code)
        showEmailWaitlistWebViewController(url: signUpURL)
    }

    private func createAttributedWaitlistSummary() -> NSAttributedString {
        return createAttributedString(text: UserText.emailWaitlistSummary, highlights: [
            (text: "Learn more", link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }

    private func createAttributedWaitlistJoinedWithNotificationSummary() -> NSAttributedString {
        return createAttributedString(text: UserText.emailWaitlistJoinedWithNotificationSummary, highlights: [
            (text: "Learn more", link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }

    private func createAttributedWaitlistInvitedSummary() -> NSAttributedString {
        return createAttributedString(text: UserText.emailWaitlistSummary, highlights: [
            (text: "Learn more", link: AppUrls().addressBlogPostQuickLink.absoluteString)
        ])
    }

    private func createAttributedPrivacyGuaranteeString() -> NSAttributedString {
        return createAttributedString(text: UserText.emailWaitlistPrivacyGuarantee, highlights: [
            (text: "Learn more", link: AppUrls().emailPrivacyGuarantees.absoluteString)
        ])
    }

    private typealias HighlightedText = (text: String, link: String)

    private func createAttributedString(text: String, highlights: [HighlightedText]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        paragraphStyle.alignment = .center

        let text = text as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        for (highlightedValue, highlightURL) in highlights {
            let range = text.range(of: highlightedValue)

            if range.location == NSNotFound {
                continue
            }

            attributedString.addAttribute(.link, value: highlightURL, range: range)
            attributedString.addAttribute(.font, value: UIFont.boldAppFont(ofSize: 16), range: range)
            attributedString.addAttribute(.foregroundColor, value: UIColor.emailWaitlistLinkColor.cgColor, range: range)
        }

        return attributedString
    }

    fileprivate func showEmailWaitlistWebViewController(url: URL) {
        let storyboard = UIStoryboard(name: "Settings", bundle: Bundle.main)
        let view = storyboard.instantiateViewController(identifier: "EmailWaitlistWebViewController") { (coder) -> EmailWaitlistWebViewController? in
            return EmailWaitlistWebViewController(
                coder: coder,
                baseURL: url
            )
        }

        navigationController?.pushViewController(view, animated: true)
    }

}

extension EmailWaitlistViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
    }

}

extension EmailWaitlistViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        showEmailWaitlistWebViewController(url: URL)
        return false
    }

}

extension EmailWaitlistViewController: EmailManagerRequestDelegate {

    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager,
                      requested url: URL,
                      method: String,
                      headers: [String: String],
                      parameters: [String: String]?,
                      timeoutInterval: TimeInterval,
                      completion: @escaping (Data?, Error?) -> Void) {
        APIRequest.request(url: url,
                           method: APIRequest.HTTPMethod(rawValue: method) ?? .post,
                           parameters: parameters,
                           headers: headers,
                           timeoutInterval: timeoutInterval) { response, error in

            completion(response?.data, error)
        }
    }
    // swiftlint:enable function_parameter_count

}
