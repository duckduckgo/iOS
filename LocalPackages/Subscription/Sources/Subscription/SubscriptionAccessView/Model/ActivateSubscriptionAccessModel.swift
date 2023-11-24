//
//  ActivateSubscriptionAccessModel.swift
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

public final class ActivateSubscriptionAccessModel: SubscriptionAccessModel {
    public var actionHandlers: SubscriptionAccessActionHandlers
    public var title = UserText.activateModalTitle
    public var description = UserText.activateModalDescription

    public init(actionHandlers: SubscriptionAccessActionHandlers) {
        self.actionHandlers = actionHandlers
    }

    public func description(for channel: AccessChannel) -> String {
        switch channel {
        case .appleID:
            return UserText.activateModalAppleIDDescription
        case .email:
            return UserText.activateModalEmailDescription
        case .sync:
            return UserText.activateModalSyncDescription
        }
    }

    public func buttonTitle(for channel: AccessChannel) -> String? {
        switch channel {
        case .appleID:
            return UserText.restorePurchasesButton
        case .email:
            return UserText.enterEmailButton
        case .sync:
            return UserText.goToSyncSettingsButton
        }
    }

    public func handleAction(for channel: AccessChannel) {
        switch channel {
        case .appleID:
            actionHandlers.restorePurchases()
        case .email:
            actionHandlers.openURLHandler(.activateSubscriptionViaEmail)
        case .sync:
            actionHandlers.goToSyncPreferences()
        }
    }
}
