//
//  ShareSubscriptionAccessModel.swift
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

public final class ShareSubscriptionAccessModel: SubscriptionAccessModel {
    public var title = UserText.shareModalTitle
    public var description = UserText.shareModalDescription

    private var actionHandlers: SubscriptionAccessActionHandlers

    private var email: String?
    private var hasEmail: Bool { !(email?.isEmpty ?? true) }

    public init(actionHandlers: SubscriptionAccessActionHandlers, email: String?) {
        self.actionHandlers = actionHandlers
        self.email = email
    }

    public func descriptionHeader(for channel: AccessChannel) -> String? {
        hasEmail && channel == .email ? email : nil
    }

    public func description(for channel: AccessChannel) -> String {
        switch channel {
        case .appleID:
            return UserText.shareModalAppleIDDescription
        case .email:
            return hasEmail ? UserText.shareModalNoEmailDescription : UserText.shareModalHasEmailDescription
        case .sync:
            return UserText.shareModalSyncDescription
        }
    }

    public func buttonTitle(for channel: AccessChannel) -> String? {
        switch channel {
        case .appleID:
            return nil
        case .email:
            return hasEmail ? UserText.manageEmailButton : UserText.enterEmailButton
        case .sync:
            return UserText.goToSyncSettingsButton
        }
    }

    public func handleAction(for channel: AccessChannel) {
        switch channel {
        case .appleID:
            actionHandlers.restorePurchases()
        case .email:
            let url: URL = hasEmail ? .manageSubscriptionEmail : .addEmailToSubscription

            Task {
                await AppStoreAccountManagementFlow.refreshAuthTokenIfNeeded()

                DispatchQueue.main.async {
                    self.actionHandlers.openURLHandler(url)
                }
            }
        case .sync:
            actionHandlers.goToSyncPreferences()
        }
    }
}
