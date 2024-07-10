//
//  ToggleExpandButtonView.swift
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

struct ToggleExpandButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    let direction: Direction

    func makeBody(configuration: Configuration) -> some View {
        let isDark = colorScheme == .dark

        HStack(spacing: 0) {
            VStack {
                ExpandButtonDivider()
            }
            ZStack {
                Circle()
                    .stroke(Color(designSystemColor: .lines), lineWidth: 1)
                    .frame(width: 32)
                    .if(configuration.isPressed, transform: {
                        $0.background(Circle()
                            .fill(isDark ? Color.tint(0.12) : Color.shade(0.06)))
                    })
                    .background(
                        Circle()
                            .fill(Color(designSystemColor: .background))
                    )
                Image(direction.image)
                    .resizable()
                    .foregroundColor(Color(designSystemColor: .icons))
                    .frame(width: 16, height: 16)
            }
            VStack {
                ExpandButtonDivider()
            }
        }
    }

    enum Direction {
        case up
        case down

        var image: ImageResource {
            switch self {
            case .up:
                return .chevronUp
            case .down:
                return .chevronDown
            }
        }
    }
}

private struct ExpandButtonDivider: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(Color(designSystemColor: .lines))
    }
}

#Preview {
    HStack {
        Button("", action: {}).buttonStyle(ToggleExpandButtonStyle(direction: .down))
        Button("", action: {}).buttonStyle(ToggleExpandButtonStyle(direction: .up))
    }
}
