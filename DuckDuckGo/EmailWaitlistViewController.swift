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
    @IBOutlet weak var headerDescriptionTextView: UITextView!
    @IBOutlet weak var footerTextView: UITextView! {
        didSet {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.16

            let linkAttributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key.paragraphStyle: paragraphStyle,
                NSAttributedString.Key.font: 16,
                NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor")!
            ]

            footerTextView.linkTextAttributes = linkAttributes
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
        UIApplication.shared.open(AppUrls().signUpQuickLink, options: [:], completionHandler: nil)
    }

    @IBAction func existingDuckAddressButtonTapped(_ sender: UIButton) {
        UIApplication.shared.open(AppUrls().emailLoginQuickLink, options: [:], completionHandler: nil)
    }

    // MARK: - Private

    private func applyWaitlistButtonStyle(to button: UIButton, hasSolidBackground: Bool = false) {
        let color = UIColor(named: "AccentColor")!.cgColor

        button.layer.cornerRadius = button.bounds.height / 2
        button.layer.borderWidth = 2.0
        button.layer.borderColor = color

        if hasSolidBackground {
            button.layer.backgroundColor = UIColor(named: "AccentColor")!.cgColor
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
        headerDescriptionTextView.attributedText = createAttributedWaitlistJoinedSummary()
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
        let alertController = UIAlertController(title: "Would you like to us to notify you when it’s your turn?",
                                                message: "We’ll send you a notification when you can start using Email Protection.",
                                                preferredStyle: .alert)

        alertController.addAction(title: "No Thanks", style: .cancel)

        alertController.addAction(title: "Notify Me", style: .default, handler: {
            EmailWaitlistStatus.showWaitlistNotification = true
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
                EmailWaitlistStatus.scheduleBackgroundRefreshTask()
            }
        }
    }

    private func getStarted() {
        guard let code = emailManager.inviteCode else {
            assertionFailure("\(#file): Tried to get started but no invite code was present")
            return
        }

        let signUpURL = AppUrls().signUpWithCodeQuickLink(code: code)
        UIApplication.shared.open(signUpURL, options: [:], completionHandler: nil)
    }

    private func createAttributedWaitlistSummary() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        paragraphStyle.alignment = .center

        let text = UserText.emailWaitlistSummary as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        let linkRange = text.range(of: "Announcement")

        if linkRange.location == NSNotFound {
            return attributedString
        }

        let urls = AppUrls()
        attributedString.addAttribute(.link, value: urls.addressBlogPostQuickLink.absoluteString, range: linkRange)

        return attributedString
    }

    private func createAttributedWaitlistJoinedSummary() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        paragraphStyle.alignment = .center

        let text = UserText.emailWaitlistJoinedSummary as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        let linkRange = text.range(of: "Announcement")

        if linkRange.location == NSNotFound {
            return attributedString
        }

        let urls = AppUrls()
        attributedString.addAttribute(.link, value: urls.addressBlogPostQuickLink.absoluteString, range: linkRange)

        return attributedString
    }

    private func createAttributedWaitlistInvitedSummary() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.22
        paragraphStyle.alignment = .center

        let text = UserText.emailWaitlistInvitedSummary as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        let linkRange = text.range(of: "Announcement")

        if linkRange.location == NSNotFound {
            return attributedString
        }

        let urls = AppUrls()
        attributedString.addAttribute(.link, value: urls.addressBlogPostQuickLink.absoluteString, range: linkRange)

        return attributedString
    }

    private func createAttributedPrivacyGuaranteeString() -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.16
        paragraphStyle.alignment = .center

        let text = UserText.emailWaitlistPrivacyGuarantee as NSString
        let attributedString = NSMutableAttributedString(string: text as String, attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.appFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel
        ])

        let range = text.range(of: "Learn more")

        if range.location == NSNotFound {
            return attributedString
        }

        let urls = AppUrls()
        attributedString.addAttribute(.link, value: urls.privacyGuaranteesQuickLink.absoluteString, range: range)

        return attributedString
    }

}

extension EmailWaitlistViewController: Themable {
    
    func decorate(with theme: Theme) {
        view.backgroundColor = theme.backgroundColor
    }

}

extension EmailWaitlistViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        return true
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
