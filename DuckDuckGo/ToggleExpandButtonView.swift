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
                configuration.label
                    .foregroundColor(isDark ? .tint(0.6) : .shade(0.6))
                    .frame(width: 16, height: 16)
            }
            VStack {
                ExpandButtonDivider()
            }
        }
    }
}

private struct ExpandButtonDivider: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 1)
            .foregroundColor(Color(designSystemColor: .lines))
    }
}

#Preview {
    VStack {
        Button(action: {},
               label: {
            Image(.chevronDown)
                .resizable()
        }).buttonStyle(ToggleExpandButtonStyle())

        Button(action: {},
               label: {
            Image(.chevronUp)
                .resizable()
        }).buttonStyle(ToggleExpandButtonStyle())
    }
}
