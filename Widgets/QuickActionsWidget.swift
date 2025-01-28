//
//  QuickActionsWidget.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

struct QuickActionsWidget: Widget {
    let kind: String = "QuickActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { _ in
            QuickActionsWidgetView().widgetURL(DeepLinks.openAIChat)
        }
        .configurationDisplayName(UserText.quickActionsWidgetGalleryDisplayName)
        .description(UserText.quickActionsWidgetGalleryDescription)
        .supportedFamilies([.systemSmall])
    }
}

struct QuickActionsWidgetView: View {

    var body: some View {
        VStack(spacing: 12) {
            Link(destination: DeepLinks.newSearch) {
                SearchBoxView()
            }
            HStack(spacing: 12) {
                Link(destination: DeepLinks.openAIChat.appendingParameter(name: WidgetSourceType.sourceKey, value: WidgetSourceType.quickActions.rawValue)) {
                    IconView(image: Image(.aiChat24))
                }
                Link(destination: DeepLinks.openPasswords) {
                    IconView(image: Image(.key24))
                }
            }
        }
        .widgetContainerBackground(color: Color(designSystemColor: .backgroundSheets))
    }
}

private struct SearchBoxView: View {
    var body: some View {
        HStack {
            Image(.duckDuckGoColor28)
                .resizable()
                .useFullColorRendering()
                .frame(width: 28, height: 28)
                .padding(.leading, 12)

            Text(UserText.quickActionsSearch)
                .daxBodyRegular()
                .makeAccentable()

            Spacer()
        }
        .frame(height: 52)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 46)
                .fill(Color(designSystemColor: .container))
        )
    }
}

private struct IconView: View {
    let image: Image

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(designSystemColor: .container))
            image
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .makeAccentable()
        }
        .frame(width: 60, height: 60)
    }
}

#Preview {
    QuickActionsWidgetView()
}
