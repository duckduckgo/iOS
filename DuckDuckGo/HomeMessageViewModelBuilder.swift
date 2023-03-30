//
//  HomeMessageViewModelBuilder.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
import Core

struct HomeMessageViewModelBuilder {

    private enum Images {
        static let announcement      = "RemoteMessageAnnouncement"
        static let ddgAnnouncement   = "RemoteMessageDDGAnnouncement"
        static let appUpdate         = "RemoteMessageAppUpdate"
        static let criticalAppUpdate = "RemoteMessageCriticalAppUpdate"
    }

    static func build(for remoteMessage: RemoteMessageModel, onDidClose: @escaping (HomeMessageViewModel.ButtonAction?) -> Void) -> HomeMessageViewModel? {
            guard let content = remoteMessage.content else { return nil }

            switch content {
            case .small(let titleText, let descriptionText):
                return HomeMessageViewModel(image: nil,
                                            topText: nil,
                                            title: titleText,
                                            subtitle: descriptionText,
                                            buttons: [],
                                            onDidClose: onDidClose)
            case .medium(let titleText, let descriptionText, let placeholder):
                return HomeMessageViewModel(image: placeholder.rawValue,
                                            topText: nil,
                                            title: titleText,
                                            subtitle: descriptionText,
                                            buttons: [],
                                            onDidClose: onDidClose)
            case .bigSingleAction(let titleText, let descriptionText, let placeholder, let primaryActionText, let primaryAction):
                return HomeMessageViewModel(image: placeholder.rawValue,
                                            topText: nil,
                                            title: titleText,
                                            subtitle: descriptionText,
                                            buttons: [
                                                HomeMessageButtonViewModel(title: primaryActionText,
                                                                           action: mapActionToViewModel(remoteAction: primaryAction,
                                                                                                        buttonAction: .primaryAction,
                                                                                                        onDidClose: onDidClose))],
                                            onDidClose: onDidClose)
            case .bigTwoAction(let titleText, let descriptionText, let placeholder, let primaryActionText,
                               let primaryAction, let secondaryActionText, let secondaryAction):
                return HomeMessageViewModel(image: placeholder.rawValue,
                                            topText: nil,
                                            title: titleText,
                                            subtitle: descriptionText,
                                            buttons: [
                                                HomeMessageButtonViewModel(title: secondaryActionText,
                                                                           actionStyle: .cancel,
                                                                           action: mapActionToViewModel(remoteAction: secondaryAction,
                                                                                                        buttonAction: .secondaryAction,
                                                                                                        onDidClose: onDidClose)),
                                                HomeMessageButtonViewModel(title: primaryActionText,
                                                                           actionStyle: .default,
                                                                           action: mapActionToViewModel(remoteAction: primaryAction,
                                                                                                        buttonAction: .primaryAction,
                                                                                                        onDidClose: onDidClose))],
                                            onDidClose: onDidClose)
            }
    }

    static func mapActionToViewModel(remoteAction: RemoteAction,
                                     buttonAction: HomeMessageViewModel.ButtonAction,
                                     onDidClose: @escaping (HomeMessageViewModel.ButtonAction?) -> Void) -> () -> Void {
        switch remoteAction {
        case .url(let value):
            return {
                LaunchTabNotification.postLaunchTabNotification(urlString: value)
                onDidClose(buttonAction)
            }
        case .appStore:
            return {
                let url = URL.appStore
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.open(url)
                }
                onDidClose(buttonAction)
            }
        case .dismiss:
            return {
                onDidClose(buttonAction)
            }
        }
    }
}
