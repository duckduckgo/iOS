//
//  ShortcutItemView.swift
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

import DesignResourcesKit
import SwiftUI

struct ShortcutItemView: View {
    let shortcut: NewTabPageShortcut
    let accessoryType: ShortcutAccessoryType?

    var body: some View {
        VStack(spacing: 6) {
            ShortcutIconView(shortcut: shortcut)
                .overlay(alignment: .topTrailing) {
                    if let accessoryType {
                        ShortcutAccessoryView(accessoryType: accessoryType)
                            .alignedForOverlay(edgeSize: Constant.accessorySize)
                    }
                }

            Text(shortcut.name)
                .font(Font.system(size: 12))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .frame(maxWidth: .infinity, alignment: .top)
        }
    }

    private enum Constant {
        static let accessorySize = 24.0
    }
}

struct ShortcutIconView: View {
    let shortcut: NewTabPageShortcut

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(designSystemColor: .surface))
                .shadow(color: .shade(0.12), radius: 0.5, y: 1)
                .aspectRatio(1, contentMode: .fit)
                .frame(width: NewTabPageGrid.Item.edgeSize)
            Image(shortcut.imageResource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: NewTabPageGrid.Item.edgeSize * 0.5)
        }
    }
}

private extension NewTabPageShortcut {
    var name: String {
        switch self {
        case .bookmarks:
            UserText.newTabPageShortcutBookmarks
        case .aiChat:
            UserText.newTabPageShortcutAIChat
        case .passwords:
            UserText.newTabPageShortcutPasswords
        case .downloads:
            UserText.newTabPageShortcutDownloads
        case .settings:
            UserText.newTabPageShortcutSettings
        }
    }

    var imageResource: ImageResource {
        switch self {
        case .bookmarks:
            return .bookmarksColor32
        case .aiChat:
            return .aiChatColor32
        case .passwords:
            return .passwordsAutofillColor32
        case .downloads:
            return .downloadsColor32
        case .settings:
            return .settingsColor32
        }
    }
}

private extension ShortcutAccessoryView {
    @ViewBuilder func alignedForOverlay(edgeSize: CGFloat) -> some View {
        let offset = CGSize(width: edgeSize/4.0, height: -edgeSize/4.0)
        let size = CGSize(width: edgeSize, height: edgeSize)
        
        if #available(iOS 16, *) {
            frame(width: edgeSize)
                .offset(offset)
        } else {
            frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .offset(offset)
        }
    }
}

#Preview {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 86))], content: {
            let accessoryTypes: [ShortcutAccessoryType?] = [.none, .add, .selected]
            
            ForEach(accessoryTypes, id: \.?.hashValue) { type in
                Section {
                    ForEach(NewTabPageShortcut.allCases) { shortcut in
                        ShortcutItemView(shortcut: shortcut, accessoryType: type)
                    }
                    
                } footer: {
                    Spacer(minLength: 12)
                    Divider()
                    Spacer(minLength: 12)
                }
            }
        })
        .padding(8)
    }
    .background(Color(designSystemColor: .background))
}
