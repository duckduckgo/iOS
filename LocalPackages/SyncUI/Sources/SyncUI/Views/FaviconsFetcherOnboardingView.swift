//
//  FaviconsFetcherOnboardingView.swift
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
import DuckUI
import DesignResourcesKit

public struct FaviconsFetcherOnboardingView: View {

    @Environment(\.verticalSizeClass) var verticalSizeClass

    var isCompact: Bool {
        verticalSizeClass == .compact
    }

    public init(model: FaviconsFetcherOnboardingViewModel) {
        self.model = model
    }

    @ObservedObject public var model: FaviconsFetcherOnboardingViewModel

    public var body: some View {
        UnderflowContainer {
            VStack(spacing: 12) {
                Image("Sync-Start-128")
                    .padding(.bottom, 12)

                Text(UserText.fetchFaviconsOnboardingTitle)
                    .daxTitle3()

                Text(UserText.fetchFaviconsOnboardingMessage)
                    .multilineTextAlignment(.center)
                    .daxBodyRegular()
                    .padding(.bottom, 24)

                Text(UserText.options.uppercased())
                    .daxFootnoteRegular()
                Toggle(isOn: $model.isFaviconsFetchingEnabled) {
                    VStack(alignment: .leading) {
                        Text(UserText.fetchFaviconsOnboardingOptionTitle)
                            .foregroundColor(.primary)
                            .daxBodyRegular()
                        Text(UserText.fetchFaviconsOnboardingOptionCaption)
                            .daxCaption()
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.01))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black.opacity(0.2), lineWidth: 0.2)
                )
            }
            .padding(.horizontal, 20)

        } foregroundContent: {
            Button {
                withAnimation {
                    model.onDismiss()
                }
            } label: {
                Text("Dismiss")
            }
            .buttonStyle(PrimaryButtonStyle())
            .frame(maxWidth: 360)
            .padding(.horizontal, 30)
        }
        .padding(.top, isCompact ? 0 : 24)
        .padding(.bottom)
    }
}
