//
//  MainViewController+Email.swift
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

import Foundation
import BrowserServicesKit
import Networking
import Core

extension MainViewController {

    func newEmailAddress() {
        guard emailManager.isSignedIn else {
            UIApplication.shared.open(URL.emailProtectionQuickLink, options: [:], completionHandler: nil)
            return
        }

        var pixelParameters: [String: String] = [:]

        if let cohort = emailManager.cohort {
            pixelParameters[PixelParameters.emailCohort] = cohort
        }
        pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
        emailManager.updateLastUseDate()

        Pixel.fire(pixel: .emailUserCreatedAlias, withAdditionalParameters: pixelParameters, includedParameters: [])

        let emailManager = self.emailManager
        emailManager.getAliasIfNeededAndConsume { alias, _ in
            Task { @MainActor in
                guard let alias = alias else {
                    // we may want to communicate this failure to the user in the future
                    return
                }
                let pasteBoard = UIPasteboard.general
                pasteBoard.string = emailManager.emailAddressFor(alias)
                let addressBarBottom = self.appSettings.currentAddressBarPosition.isBottom
                ActionMessageView.present(message: UserText.emailBrowsingMenuAlert,
                                          presentationLocation: .withBottomBar(andAddressBarBottom: addressBarBottom))
            }
        }
    }

}

// MARK: - EmailManagerRequestDelegate
extension MainViewController: EmailManagerRequestDelegate {

    // swiftlint:disable function_parameter_count
    func emailManager(_ emailManager: EmailManager, requested url: URL, method: String, headers: HTTPHeaders, parameters: [String: String]?, httpBody: Data?, timeoutInterval: TimeInterval) async throws -> Data {
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

// MARK: - EmailManagerAliasPermissionDelegate
extension MainViewController: EmailManagerAliasPermissionDelegate {

    func emailManager(_ emailManager: EmailManager,
                      didRequestPermissionToProvideAliasWithCompletion: @escaping (EmailManagerPermittedAddressType, Bool) -> Void) {

        DispatchQueue.main.async {
            let emailAddressPromptViewController = EmailAddressPromptViewController(emailManager) { addressType, autosave in
                didRequestPermissionToProvideAliasWithCompletion(addressType, autosave)
            }

            if #available(iOS 15.0, *) {
                if let presentationController = emailAddressPromptViewController.presentationController as? UISheetPresentationController {
                    if #available(iOS 16.0, *) {
                        presentationController.detents = [.custom(resolver: { _ in
                            AutofillViews.emailSignupPromptMinHeight
                        })]
                    } else {
                        presentationController.detents = [.medium()]
                    }
                }
            }
            self.present(emailAddressPromptViewController, animated: true)
        }

    }

    func emailManager(_ emailManager: EmailManager, didRequestInContextSignUp completionHandler: @escaping (_ shouldContinue: Bool) -> Void) {

        let emailSignupPromptViewController = EmailSignupPromptViewController { shouldContinue in
            if shouldContinue {
                let signupViewController = EmailSignupViewController { shouldContinue in
                    completionHandler(shouldContinue)
                }
                let signupNavigationController = UINavigationController(rootViewController: signupViewController)
                self.present(signupNavigationController, animated: true, completion: nil)
            } else {
                completionHandler(shouldContinue)
            }
        }

        if #available(iOS 15.0, *) {
            if let presentationController = emailSignupPromptViewController.presentationController as? UISheetPresentationController {
                if #available(iOS 16.0, *) {
                    presentationController.detents = [.custom(resolver: { _ in
                        AutofillViews.emailSignupPromptMinHeight
                    })]
                } else {
                    presentationController.detents = [.medium()]
                }
            }
        }

        self.present(emailSignupPromptViewController, animated: true)

    }

}

// MARK: - UIPopoverPresentationControllerDelegate
extension MainViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
