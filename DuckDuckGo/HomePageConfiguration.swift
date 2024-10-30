//
//  HomePageConfiguration.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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
import RemoteMessaging
import Common
import Core
import Bookmarks
import os.log

final class HomePageConfiguration: HomePageMessagesConfiguration {
    
    // MARK: - Messages
    
    private var homeMessageStorage: HomeMessageStorage
    private var remoteMessagingClient: RemoteMessagingClient
    private let privacyProDataReporter: PrivacyProDataReporting

    var homeMessages: [HomeMessage] = []

    init(variantManager: VariantManager? = nil,
         remoteMessagingClient: RemoteMessagingClient,
         privacyProDataReporter: PrivacyProDataReporting) {
        homeMessageStorage = HomeMessageStorage(variantManager: variantManager)
        self.remoteMessagingClient = remoteMessagingClient
        self.privacyProDataReporter = privacyProDataReporter
        homeMessages = buildHomeMessages()
    }

    func refresh() {
        homeMessages = buildHomeMessages()
    }

    private func buildHomeMessages() -> [HomeMessage] {
        var messages = homeMessageStorage.messagesToBeShown

        if DaxDialogs.shared.isStillOnboarding() {
            return messages
        }

        guard let remoteMessage = remoteMessageToShow() else {
            return messages
        }

        messages.append(remoteMessage)
        return messages
    }

    private func remoteMessageToShow() -> HomeMessage? {
        guard let remoteMessageToPresent = remoteMessagingClient.store.fetchScheduledRemoteMessage() else { return nil }
        Logger.remoteMessaging.info("Remote message to show: \(remoteMessageToPresent.id)")
        return .remoteMessage(remoteMessage: remoteMessageToPresent)
    }

    @MainActor
    func dismissHomeMessage(_ homeMessage: HomeMessage) async {
        switch homeMessage {
        case .remoteMessage(let remoteMessage):
            Logger.remoteMessaging.info("Home message dismissed: \(remoteMessage.id)")
            await remoteMessagingClient.store.dismissRemoteMessage(withID: remoteMessage.id)

            if let index = homeMessages.firstIndex(of: homeMessage) {
                homeMessages.remove(at: index)
            }
        default:
            break
        }
    }

    func didAppear(_ homeMessage: HomeMessage) {
        switch homeMessage {
        case .remoteMessage(let remoteMessage):
            Logger.remoteMessaging.info("Remote message shown: \(remoteMessage.id)")
            if remoteMessage.isMetricsEnabled {
                Pixel.fire(pixel: .remoteMessageShown,
                           withAdditionalParameters: additionalParameters(for: remoteMessage.id))
            }

            if !remoteMessagingClient.store.hasShownRemoteMessage(withID: remoteMessage.id) {
                Logger.remoteMessaging.info("Remote message shown for first time: \(remoteMessage.id)")
                if remoteMessage.isMetricsEnabled {
                    Pixel.fire(pixel: .remoteMessageShownUnique,
                               withAdditionalParameters: additionalParameters(for: remoteMessage.id))
                }
                Task {
                    await remoteMessagingClient.store.updateRemoteMessage(withID: remoteMessage.id, asShown: true)
                }
            }

        default:
            break
        }

    }

    private func additionalParameters(for messageID: String) -> [String: String] {
        privacyProDataReporter.mergeRandomizedParameters(for: .messageID(messageID),
                                                         with: [PixelParameters.message: "\(messageID)"])
    }
}
