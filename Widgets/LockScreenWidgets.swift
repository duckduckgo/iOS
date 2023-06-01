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

// Search
// Voice Search
// Email Protection
// Fire Button
// Favorites

@available(iOSApplicationExtension 16.0, *)
struct SearchLockScreenWidget: Widget {

    let kind: String = "SearchLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            return LockScreenWidgetView(imageNamed: "LockScreenSearch")
                .widgetURL(DeepLinks.newSearch)
        }
        .configurationDisplayName("DuckDuckGo Search")
        .description("Quickly launch a private search in DuckDuckGo.")
        .supportedFamilies([ .accessoryCircular ])
    }

}

@available(iOSApplicationExtension 16.0, *)
struct FavoritesLockScreenWidget: Widget {

    let kind: String = "FavoritesLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            return LockScreenWidgetView(imageNamed: "LockScreenFavorites")
                .widgetURL(DeepLinks.favorites)
        }
        .configurationDisplayName("DuckDuckGo Favorites")
        .description("Quickly access your favorites in DuckDuckGo.")
        .supportedFamilies([ .accessoryCircular ])
    }
}

@available(iOSApplicationExtension 16.0, *)
struct VoiceSearchLockScreenWidget: Widget {

    let kind: String = "VoiceSearchLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            return LockScreenWidgetView(imageNamed: "LockScreenVoice")
                .widgetURL(DeepLinks.voiceSearch)
        }
        .configurationDisplayName("DuckDuckGo Voice Search")
        .description("Quickly launch a private voice search in DuckDuckGo.")
        .supportedFamilies([ .accessoryCircular ])
    }

}

@available(iOSApplicationExtension 16.0, *)
struct EmailProtectionLockScreenWidget: Widget {

    let kind: String = "EmailProtectionLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            return LockScreenWidgetView(imageNamed: "LockScreenEmail")
                .widgetURL(DeepLinks.emailProtection)
        }
        .configurationDisplayName("DuckDuckGo Email Protection")
        .description("Quickly launch DuckDuckGo Email Protection.")
        .supportedFamilies([ .accessoryCircular ])
    }

}

@available(iOSApplicationExtension 16.0, *)
struct FireButtonLockScreenWidget: Widget {

    let kind: String = "FireButtonLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            return LockScreenWidgetView(imageNamed: "LockScreenFire")
                .widgetURL(DeepLinks.fireButton)
        }
        .configurationDisplayName("DuckDuckGo Fire Button")
        .description("Burn all data and launch a private search in DuckDuckGo.")
        .supportedFamilies([ .accessoryCircular ])
    }
}

struct LockScreenWidgetView: View {

    let imageNamed: String

    var body: some View {
        ZStack {
            Image(imageNamed)
                .resizable()

            Image("Logo")
                .resizable()
                .frame(width: 24, height: 24)
                .offset(y: 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}
