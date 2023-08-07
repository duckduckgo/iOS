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
                ActionMessageView.present(message: UserText.emailBrowsingMenuAlert)
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

// MARK: - EmailManagerAliasPermissionDelegate
extension MainViewController: EmailManagerAliasPermissionDelegate {

    func emailManager(_ emailManager: BrowserServicesKit.EmailManager, didRequestPermissionToProvideAliasWithCompletion: @escaping (BrowserServicesKit.EmailManagerPermittedAddressType, Bool) -> Void) {

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

                    didRequestPermissionToProvideAliasWithCompletion(.user, false)
                }
            }

            alert.addAction(title: UserText.emailAliasAlertGeneratePrivateAddress) {
                pixelParameters[PixelParameters.emailLastUsed] = emailManager.lastUseDate
                emailManager.updateLastUseDate()

                Pixel.fire(pixel: .emailUserPressedUseAlias, withAdditionalParameters: pixelParameters, includedParameters: [])

                didRequestPermissionToProvideAliasWithCompletion(.generated, true)
            }

            alert.addAction(title: UserText.emailAliasAlertDecline) {
                Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters, includedParameters: [])

                didRequestPermissionToProvideAliasWithCompletion(.none, false)
            }

            if UIDevice.current.userInterfaceIdiom == .pad {
                // make sure the completion handler is called if the alert is dismissed by tapping outside the alert
                alert.addAction(title: "", style: .cancel) {
                    Pixel.fire(pixel: .emailTooltipDismissed, withAdditionalParameters: pixelParameters)
                    didRequestPermissionToProvideAliasWithCompletion(.none, false)
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

// MARK: - UIPopoverPresentationControllerDelegate
extension MainViewController: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
