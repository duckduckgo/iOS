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

final class HomePageConfiguration {
    
    enum Component: Equatable {
        case navigationBarSearch(fixed: Bool)
        case favorites
        case homeMessage
        case appTrackingProtection
    }

    func components(favoritesViewModel: FavoritesListInteracting) -> [Component] {
        let fixed = favoritesViewModel.favorites.count == 0
        return [
            .navigationBarSearch(fixed: fixed),
            .homeMessage,
            .appTrackingProtection,
            .favorites
        ]
    }
    
    // MARK: - Messages
    
    private var homeMessageStorage: HomeMessageStorage
    private var remoteMessagingStore: RemoteMessagingStore

    var homeMessages: [HomeMessage] = []

    init(variantManager: VariantManager? = nil,
         remoteMessagingStore: RemoteMessagingStore = AppDependencyProvider.shared.remoteMessagingStore) {
        homeMessageStorage = HomeMessageStorage(variantManager: variantManager)
        self.remoteMessagingStore = remoteMessagingStore
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
        guard let remoteMessageToPresent = remoteMessagingStore.fetchScheduledRemoteMessage() else { return nil }
        os_log("Remote message to show: %s", log: .remoteMessaging, type: .info, remoteMessageToPresent.id)
        return .remoteMessage(remoteMessage: remoteMessageToPresent)
    }

    func dismissHomeMessage(_ homeMessage: HomeMessage) {
        switch homeMessage {
        case .remoteMessage(let remoteMessage):
            os_log("Home message dismissed: %s", log: .remoteMessaging, type: .info, remoteMessage.id)
            remoteMessagingStore.dismissRemoteMessage(withId: remoteMessage.id)

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
            os_log("Remote message shown: %s", log: .remoteMessaging, type: .info, remoteMessage.id)
            Pixel.fire(pixel: .remoteMessageShown,
                       withAdditionalParameters: [PixelParameters.message: "\(remoteMessage.id)"])

            if !remoteMessagingStore.hasShownRemoteMessage(withId: remoteMessage.id) {
                os_log("Remote message shown for first time: %s", log: .remoteMessaging, type: .info, remoteMessage.id)
                Pixel.fire(pixel: .remoteMessageShownUnique,
                           withAdditionalParameters: [PixelParameters.message: "\(remoteMessage.id)"])
                remoteMessagingStore.updateRemoteMessage(withId: remoteMessage.id, asShown: true)
            }

        default:
            break
        }

    }
}
