//
//  ContextualOnboardingList.swift
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

import Foundation
import SwiftUI
import DuckUI

enum ContextualOnboardingListItem: Equatable {
    case search(title: String)
    case site(title: String)
    case surprise(title: String)

    var visibleTitle: String {
        switch self {
        case .search(let title):
            return title
        case .site(let title):
            return title
        case .surprise:
            return "Surprise me"
        }
    }

    var title: String {
        switch self {
        case .search(let title):
            return title
        case .site(let title):
            return title
        case .surprise(let title):
            return title
        }
    }

    var imageName: String {
        switch self {
        case .search:
            return "SuggestLoupe"
        case .site:
            return "SuggestGlobe"
        case .surprise:
            return "Wand-16"
        }
    }
}

struct ContextualOnboardingListView: View {
    let list: [ContextualOnboardingListItem]
    var action: (_ title: String) -> Void
    let iconSize = 16.0

    var body: some View {
        VStack {
            ForEach(list.indices, id: \.self) { index in
                Button(action: {
                    action(list[index].title)
                }, label: {
                    HStack {
                        Image(list[index].imageName)
                            .frame(width: iconSize, height: iconSize)
                        Text(list[index].visibleTitle)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                })
                .buttonStyle(SecondaryButtonStyle(compact: true))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .inset(by: 0.5)
                        .stroke(.blue, lineWidth: 1)
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("List") {
    let list = [
        ContextualOnboardingListItem.search(title: "Search"),
        ContextualOnboardingListItem.site(title: "Website"),
        ContextualOnboardingListItem.surprise(title: "Surprise"),
    ]
    return ContextualOnboardingListView(list: list) { _ in }
        .padding()
}
