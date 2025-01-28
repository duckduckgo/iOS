//
//  LockScreenWidgets.swift
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

import SwiftUI
import WidgetKit

@available(iOSApplicationExtension 16.0, *)
protocol LockScreenWidget: Widget {
    var kind: String { get }
    var imageName: String { get }
    var deepLink: URL { get }
    var displayName: String { get }
    var description: String { get }
}

@available(iOSApplicationExtension 16.0, *)
extension LockScreenWidget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            LockScreenWidgetView(imageNamed: imageName)
                .widgetURL(deepLink)
        }
        .configurationDisplayName(displayName)
        .description(self.description)
        .supportedFamilies([.accessoryCircular])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct SearchLockScreenWidget: LockScreenWidget {
    let kind = "SearchLockScreenWidget"
    let imageName = "LockScreenSearch"
    let deepLink = DeepLinks.newSearch.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenSearchTitle
    let description = UserText.lockScreenSearchDescription
}

@available(iOSApplicationExtension 16.0, *)
struct FavoritesLockScreenWidget: LockScreenWidget {
    let kind = "FavoritesLockScreenWidget"
    let imageName = "LockScreenFavorites"
    let deepLink = DeepLinks.favorites.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenFavoritesTitle
    let description = UserText.lockScreenFavoritesDescription
}

@available(iOSApplicationExtension 16.0, *)
struct VoiceSearchLockScreenWidget: LockScreenWidget {
    let kind = "VoiceSearchLockScreenWidget"
    let imageName = "LockScreenVoice"
    let deepLink = DeepLinks.voiceSearch.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenVoiceTitle
    let description = UserText.lockScreenVoiceDescription
}

@available(iOSApplicationExtension 16.0, *)
struct EmailProtectionLockScreenWidget: LockScreenWidget {
    let kind = "EmailProtectionLockScreenWidget"
    let imageName = "LockScreenEmail"
    let deepLink = DeepLinks.newEmail.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenEmailTitle
    let description = UserText.lockScreenEmailDescription
}

@available(iOSApplicationExtension 16.0, *)
struct FireButtonLockScreenWidget: LockScreenWidget {
    let kind = "FireButtonLockScreenWidget"
    let imageName = "LockScreenFire"
    let deepLink = DeepLinks.fireButton.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenFireTitle
    let description = UserText.lockScreenFireDescription
}

@available(iOSApplicationExtension 16.0, *)
struct PasswordsLockScreenWidget: LockScreenWidget {
    let kind = "PasswordsLockScreenWidget"
    let imageName = "LockScreenPasswords"
    let deepLink = DeepLinks.openPasswords.appendingParameter(name: "ls", value: "1")
    let displayName = UserText.lockScreenPasswordsTitle
    let description = UserText.lockScreenPasswordsDescription
}

@available(iOSApplicationExtension 16.0, *)
struct AIChatLockScreenWidget: LockScreenWidget {
    let kind = "AIChatLockScreenWidget"
    let imageName = "LockScreenAIChat"
    let deepLink = DeepLinks.openAIChat.appendingParameter(name: WidgetSourceType.sourceKey, value: WidgetSourceType.lockscreenComplication.rawValue)
    let displayName = UserText.lockScreenAIChatTitle
    let description = UserText.lockScreenAIChatDescription
}

// MARK: - Widget View
struct LockScreenWidgetView: View {
    let imageNamed: String

    var body: some View {
        ZStack {
            Image(imageNamed)
                .resizable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Circle().foregroundColor(.white.opacity(0.3)))
        .widgetContainerBackground()
    }
}
