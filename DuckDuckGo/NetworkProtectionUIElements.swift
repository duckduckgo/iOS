//
//  NetworkProtectionUIElements.swift
//  DuckDuckGo
//
//  Copyright © 2025 DuckDuckGo. All rights reserved.
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

struct NetworkProtectionUIElements {

    struct ChecklistItem<Content>: View where Content: View {
        let isSelected: Bool
        let action: () -> Void
        @ViewBuilder let label: () -> Content

        var body: some View {
            Button(
                action: action,
                label: {
                    HStack(spacing: 12) {
                        label()
                        Spacer()
                        Image(systemName: "checkmark")
                            .tint(.init(designSystemColor: .accent))
                            .if(!isSelected) {
                                $0.hidden()
                            }
                    }
                }
            )
            .tint(Color(designSystemColor: .textPrimary))
            .listRowInsets(EdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16))
        }
    }

    struct ToggleSectionView<Content: View>: View {
        let text: String
        let headerText: String
        let footerText: String
        let toggle: Content

        init(text: String, headerText: String, footerText: String, @ViewBuilder toggle: () -> Content) {
            self.text = text
            self.headerText = headerText
            self.footerText = footerText
            self.toggle = toggle()
        }

        var body: some View {
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(text)
                            .daxBodyRegular()
                            .foregroundColor(.init(designSystemColor: .textPrimary))
                            .layoutPriority(1)
                    }

                    toggle
                        .toggleStyle(SwitchToggleStyle(tint: .init(designSystemColor: .accent)))
                }
            } header: {
                Text(headerText)
            } footer: {
                Text(LocalizedStringKey(footerText))
                    .foregroundColor(.init(designSystemColor: .textSecondary))
                    .accentColor(Color(designSystemColor: .accent))
                    .daxFootnoteRegular()
                    .padding(.top, 6)
            }
            .listRowBackground(Color(designSystemColor: .surface))
        }
    }

    struct MenuItem: View {
        let isSelected: Bool
        let title: String
        let action: () -> Void

        var body: some View {
            Button(
                action: action,
                label: {
                    HStack(spacing: 12) {
                        Text(title).daxBodyRegular()
                        Spacer()
                        Image(systemName: "checkmark")
                            .if(!isSelected) {
                                $0.hidden()
                            }
                            .tint(Color(designSystemColor: .textPrimary))
                    }
                }
            )
            .tint(Color(designSystemColor: .textPrimary))
        }
    }
}
