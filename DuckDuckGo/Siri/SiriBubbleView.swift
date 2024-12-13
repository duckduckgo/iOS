//
//  SiriBubbleView.swift
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
import SwiftUICore

private struct SiriBubble: Shape {

    static let tipHeight: CGFloat = 7

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cornerRadius: CGFloat = 21
        let tipHeight: CGFloat = 7
        let tipWidth: CGFloat = 9

        // Rounded rectangle portion
        let roundedRect = CGRect(
            x: rect.minX,
            y: rect.minY,
            width: rect.width,
            height: rect.height - Self.tipHeight
        )
        path.addRoundedRect(in: roundedRect, cornerSize: CGSize(width: cornerRadius, height: cornerRadius))

        // Triangle tip drawn out of bounds
        let tipStartX = rect.maxX - (cornerRadius + 2 * tipWidth)
        let tipBaseY = rect.maxY - Self.tipHeight

        path.move(to: CGPoint(x: tipStartX, y: tipBaseY)) // Bottom-right corner of rounded rectangle
        path.addLine(to: CGPoint(x: tipStartX + tipWidth, y: tipBaseY)) // Tip top-right
        path.addLine(to: CGPoint(x: tipStartX, y: tipBaseY + tipHeight)) // Tip bottom-right (out of bounds)
        path.closeSubpath()

        return path
    }
}

struct SiriBubbleView: View {

    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(alignment: .center) {
            Text(text)
                .foregroundStyle(Color(designSystemColor: .textPrimary))
                .multilineTextAlignment(.center)
        }.padding(12)
            .padding(.bottom, SiriBubble.tipHeight)
            .frame(maxWidth: .infinity)
            .background(SiriBubble()
                .fill(Color(designSystemColor: .surface))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2))
    }
}
