//
//  ToggleExpandButtonStyle.swift
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
import DesignResourcesKit

struct ToggleExpandButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor = configuration.isPressed ? Color(designSystemColor: .buttonsSecondaryFillPressed) : Color(designSystemColor: .buttonsSecondaryFillDefault)

        HStack(spacing: 0) {
            VStack {
                ExpandButtonDivider()
            }

            Circle()
                .stroke(Color(designSystemColor: .lines), lineWidth: 1)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(backgroundColor)
                )
                .overlay {
                    configuration.label
                        .foregroundColor(Color(designSystemColor: .iconsSecondary))
                        .frame(width: 16, height: 16)
                        
                }

            VStack {
                ExpandButtonDivider()
            }
        }
        .padding(.vertical, 0.5) // Adjust padding for drawing group, otherwise the circle stroke is clipped
        .drawingGroup()
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
