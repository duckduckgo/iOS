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

struct ShortcutAccessoryView: View {

    let accessoryType: ShortcutAccessoryType

    var body: some View {
        Circle()
            .foregroundStyle(accessoryType.backgroundColor)
            .overlay {
                Image(accessoryType.iconResource)
                    .foregroundColor(accessoryType.foregroundColor)
                    .aspectRatio(contentMode: .fit)
            }
            .shadow(color: .shade(0.15), radius: 1, y: 1)
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

    var backgroundColor: Color {
        switch self {
        case .selected:
            Color(designSystemColor: .accent)
        case .add:
            Color(designSystemColor: .surface)
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
