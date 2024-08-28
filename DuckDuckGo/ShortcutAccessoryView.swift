//
//  ShortcutAccessoryView.swift
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

struct ShortcutAccessoryView: View {

    @Environment(\.colorScheme) private var colorScheme

    let accessoryType: ShortcutAccessoryType

    var body: some View {
        Circle()
            .foregroundStyle(bgColorForAccessoryType(accessoryType))
            .overlay {
                Image(accessoryType.iconResource)
                    .resizable()
                    .foregroundColor(accessoryType.foregroundColor)
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(x: Constant.imageScaleRatio, y: Constant.imageScaleRatio)
            }
            .shadow(color: .shade(0.15), radius: 1, y: 1)
    }

    func bgColorForAccessoryType(_ accessoryType: ShortcutAccessoryType) -> Color {
        switch accessoryType {
        case .selected:
            return Color(designSystemColor: .accent)
        case .add:
            // One-off exception for this particular case.
            // See https://app.asana.com/0/72649045549333/1207988345460434/f
            return colorScheme == .dark ? .gray85 : Color(designSystemColor: .surface)
        }
    }

    private enum Constant {
        static let imageScaleRatio: CGFloat = 2.0/3.0
    }
}

enum ShortcutAccessoryType {
    case selected
    case add
}

private extension ShortcutAccessoryType {
    var iconResource: ImageResource {
        switch self {
        case .selected:
            return .check16Alt
        case .add:
            return .add16
        }
    }

    var foregroundColor: Color {
        switch self {
        case .selected:
            Color(designSystemColor: .surface)
        case .add:
            Color(designSystemColor: .accent)
        }
    }
}

#Preview {
    VStack {
        ShortcutAccessoryView(accessoryType: .add).frame(width: 24)
        ShortcutAccessoryView(accessoryType: .selected).frame(width: 24)
    }
}
