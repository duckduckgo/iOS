//
//  TextZoomEditorView.swift
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

struct TextZoomEditorView: View {

    @ObservedObject var model: TextZoomEditorModel

    @Environment(\.dismiss) var dismiss

    @ViewBuilder
    func header() -> some View {
        ZStack(alignment: .top) {
            Text(model.title)
                .font(Font(uiFont: .daxHeadline()))
                .frame(alignment: .center)
                .foregroundStyle(Color(designSystemColor: .textPrimary))

            Button {
                model.onDismiss()
                dismiss()
            } label: {
                Text(UserText.navigationTitleDone)
                    .font(Font(uiFont: .daxHeadline()))
            }
            .buttonStyle(.plain)
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .topTrailing)
            .foregroundStyle(Color(designSystemColor: .textPrimary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 17)
    }

    func slider() -> some View {
        HStack(spacing: 6) {
            Button {
                model.decrement()
            } label: {
                Image("Font-Smaller-24")
            }
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .padding(12)
            .padding(.leading, 8)

            IntervalSliderRepresentable(
                value: $model.value,
                steps: TextZoomLevel.allCases.map { $0.rawValue })
            .padding(.vertical)

            Button {
                model.increment()
            } label: {
                Image("Font-Larger-24")
            }
            .foregroundColor(Color(designSystemColor: .textPrimary))
            .padding(12)
            .padding(.trailing, 8)
        }
        .background(RoundedRectangle(cornerRadius: 8)
            .foregroundColor(Color(designSystemColor: .surface)))
        .frame(height: 64)
        .padding(.horizontal, 16)

    }

    func settingsMessage() -> some View {
        Text("Change the default zoom for all sites in [Settings](https://duckduckgo.com)")
            .lineLimit(2)
            .font(Font(uiFont: .daxFootnoteRegular()))
            .environment(\.openURL, OpenURLAction(handler: { _ in

                dismiss()

                NotificationCenter.default.post(
                    name: .settingsDeepLinkNotification,
                    object: SettingsViewModel.SettingsDeepLinkSection.accessibility,
                    userInfo: nil
                )
                return .handled
            }))
            .padding(.horizontal, 8)
    }

    func domain() -> some View {
        Text(model.domain)
            .font(Font(uiFont: .daxFootnoteRegular()))
            .frame(alignment: .center)
            .foregroundStyle(Color(designSystemColor: .textSecondary))
    }

    var body: some View {
        VStack(spacing: 0) {
            header()

            domain()
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                slider()

                if model.coordinator.shouldShowSettingsMessage {
                    settingsMessage()
                        .padding(.top)
                }

                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(designSystemColor: .background))
    }

}
