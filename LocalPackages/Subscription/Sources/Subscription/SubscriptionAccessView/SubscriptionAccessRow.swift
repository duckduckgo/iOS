//
//  SubscriptionAccessRow.swift
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import SwiftUIExtensions

public struct SubscriptionAccessRow: View {
    let iconName: String
    let name: String
    let descriptionHeader: String?
    let description: String
    let isExpanded: Bool
    let buttonTitle: String?
    let buttonAction: (() -> Void)?

    public init(iconName: String, name: String, descriptionHeader: String? = nil, description: String, isExpanded: Bool, buttonTitle: String? = nil, buttonAction: (() -> Void)? = nil) {
        self.iconName = iconName
        self.name = name
        self.descriptionHeader = descriptionHeader
        self.description = description
        self.isExpanded = isExpanded
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                Image(iconName, bundle: .module)

                Text(name)
                    .font(.system(size: 14, weight: .regular, design: .default))

                Spacer()
                    .contentShape(Rectangle())

                Image(systemName: "chevron.down")
                    .rotationEffect(Angle(degrees: isExpanded ? -180 : 0))

            }
            .padding([.top, .bottom], 8)
            .drawingGroup()

            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {

                    if let header = descriptionHeader, !header.isEmpty {
                        Text(header)
                            .bold()
                            .foregroundColor(Color("TextPrimary", bundle: .module))
                    }

                    Text(description)
                        .font(.system(size: 13, weight: .regular, design: .default))
                        .foregroundColor(Color("TextSecondary", bundle: .module))
                        .fixMultilineScrollableText()

                    if let title = buttonTitle, let action = buttonAction {
                        Spacer()
                            .frame(height: 8)
                        Button(title) { action() }
                            .buttonStyle(DefaultActionButtonStyle(enabled: true))
                    }

                    Spacer()
                        .frame(height: 4)
                }
                .transition(.asymmetric(insertion: .opacity.animation(.easeIn(duration: Constants.Animation.contentShowingDuration).delay(Constants.Animation.contentShowingDelay)),
                                        removal: .opacity.animation(.easeOut(duration: Constants.Animation.contentHidingDuration))))
            }
        }
        .animation(.easeOut(duration: Constants.Animation.duration), value: isExpanded)
    }
}

private enum Constants {

    enum Animation {
        static let duration: CGFloat = 0.3
        static let contentHidingDuration = duration * 0.6
        static let contentShowingDuration = duration
        static let contentShowingDelay = duration * 0.3
    }
}
