//
//  FavoriteSearchResultItemView.swift
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

import SwiftUI
import DuckUI
import LinkPresentation

struct FavoriteSearchResultItemView: View {
    @Environment(\.colorScheme) private var colorScheme

    let result: FavoriteSearchResult
    let isDisabled: Bool

    private var backgroundColor: Color {
        PrimaryButtonStyle.backgroundColor(colorScheme, isPressed: false, isDisabled: isDisabled)
    }

    private var foregroundColor: Color {
        PrimaryButtonStyle.foregroundColor(colorScheme, isPressed: false, isDisabled: isDisabled)
    }

    var body: some View {
        FavoriteSearchResultBaseView {
            HStack(spacing: 8) {
                icon
                    .frame(width: Metrics.iconSize, height: Metrics.iconSize)
                    .opacity(isDisabled ? 0.36 : 1.0)

                text
                    .opacity(isDisabled ? 0.36 : 1.0)

                addIcon
            }
        }
    }

    private var addIcon: some View {
        Circle()
            .fill(backgroundColor)
            .overlay {
                Image(.add16)
                    .foregroundStyle(foregroundColor)
            }
            .frame(width: 24)
    }

    private var text: some View {
        Text(verbatim: result.name)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var icon: some View {
        if let icon = result.icon {
            FavoriteIconView(favicon: Favicon(image: icon, isUsingBorder: false, isFake: false))
        } else {
            Image(.globe24)
        }
    }

    private struct Metrics {
        static let iconSize: CGFloat = 24
    }
}

#Preview {
    List {
        FavoriteSearchResultItemView(result: FavoriteSearchResult(id: "foo", name: "bar", url: URL(string: "https://foobar.url.com")!), isDisabled: false)
        FavoriteSearchResultItemView(result: FavoriteSearchResult(id: "foo", name: "bar", url: URL(string: "https://foobar.url.com")!), isDisabled: true)
    }
}
