//
//  NewTabPageMessagesModel.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

import Core
import Foundation
import RemoteMessaging

final class NewTabPageMessagesModel: ObservableObject {

    @Published private(set) var homeMessageViewModels: [HomeMessageViewModel] = []

    private var observable: NSObjectProtocol?

    private let homePageMessagesConfiguration: HomePageMessagesConfiguration
    private let notificationCenter: NotificationCenter
    private let pixelFiring: PixelFiring.Type
    private let privacyProDataReporter: PrivacyProDataReporting?

    init(homePageMessagesConfiguration: HomePageMessagesConfiguration,
         notificationCenter: NotificationCenter = .default,
         pixelFiring: PixelFiring.Type = Pixel.self,
         privacyProDataReporter: PrivacyProDataReporting? = nil) {
        self.homePageMessagesConfiguration = homePageMessagesConfiguration
        self.notificationCenter = notificationCenter
        self.pixelFiring = pixelFiring
        self.privacyProDataReporter = privacyProDataReporter
    }

    func load() {
        observable = notificationCenter.addObserver(
            forName: RemoteMessagingStore.Notifications.remoteMessagesDidChange,
            object: nil,
            queue: .main) { [weak self] _ in
                self?.refresh()
        }

        refresh()
    }

    @MainActor
    func dismissHomeMessage(_ homeMessage: HomeMessage) async {
        await homePageMessagesConfiguration.dismissHomeMessage(homeMessage)
        updateHomeMessageViewModel()
    }

    func didAppear(_ homeMessage: HomeMessage) {
        homePageMessagesConfiguration.didAppear(homeMessage)
    }

    // MARK: - Private

    private func refresh() {
        homePageMessagesConfiguration.refresh()
        updateHomeMessageViewModel()
    }

    private func updateHomeMessageViewModel() {
        self.homeMessageViewModels = homePageMessagesConfiguration.homeMessages.compactMap(self.homeMessageViewModel(for:))
    }

    private func homeMessageViewModel(for message: HomeMessage) -> HomeMessageViewModel? {
        switch message {
        case .placeholder:
            return HomeMessageViewModel(messageId: "", sendPixels: false, modelType: .small(titleText: "", descriptionText: "")) { [weak self] _ in
                await self?.dismissHomeMessage(message)
            } onDidAppear: {
                // no-op
            } onAttachAdditionalParameters: { _, params in
                params
            }
        case .remoteMessage(let remoteMessage):

            // call didAppear here to support marking messages as shown when they appear on the new tab page
            // as a result of refreshing a config while the user was on a new tab page already.
            didAppear(message)

            return HomeMessageViewModelBuilder.build(for: remoteMessage, with: privacyProDataReporter) { @MainActor [weak self] action in
                guard let action,
                      let self else { return }

                switch action {

                case .action(let isSharing):
                    if !isSharing {
                        await self.dismissHomeMessage(message)
                    }
                    if remoteMessage.isMetricsEnabled {
                        pixelFiring.fire(.remoteMessageActionClicked,
                                         withAdditionalParameters: self.additionalParameters(for: remoteMessage.id))
                    }

                case .primaryAction(let isSharing):
                    if !isSharing {
                        await self.dismissHomeMessage(message)
                    }
                    if remoteMessage.isMetricsEnabled {
                        pixelFiring.fire(.remoteMessagePrimaryActionClicked,
                                         withAdditionalParameters: self.additionalParameters(for: remoteMessage.id))
                    }

                case .secondaryAction(let isSharing):
                    if !isSharing {
                        await self.dismissHomeMessage(message)
                    }
                    if remoteMessage.isMetricsEnabled {
                        pixelFiring.fire(.remoteMessageSecondaryActionClicked,
                                         withAdditionalParameters: self.additionalParameters(for: remoteMessage.id))
                    }

                case .close:
                    await self.dismissHomeMessage(message)
                    if remoteMessage.isMetricsEnabled {
                        pixelFiring.fire(.remoteMessageDismissed,
                                         withAdditionalParameters: self.additionalParameters(for: remoteMessage.id))
                    }

                }
            } onDidAppear: { [weak self] in
                self?.didAppear(message)
            }
        }
    }

    private func additionalParameters(for messageID: String) -> [String: String] {
        let defaultParameters = [PixelParameters.message: "\(messageID)"]
        return privacyProDataReporter?.mergeRandomizedParameters(for: .messageID(messageID),
                                                                 with: defaultParameters) ?? defaultParameters
    }
}
