//
//  FaviconsFetcherOnboardingView.swift
//  DuckDuckGo
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

    public init(model: FaviconsFetcherOnboardingViewModel) {
        self.model = model
    }

    @ObservedObject public var model: FaviconsFetcherOnboardingViewModel

    public var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 24) {
                Image("SyncFetchFaviconsLogo")

                Text(UserText.fetchFaviconsOnboardingTitle)
                    .daxTitle1()

                Text(UserText.fetchFaviconsOnboardingMessage)
                    .multilineTextAlignment(.center)
                    .daxBodyRegular()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            VStack(spacing: 8) {
                Button {
                    withAnimation {
                        model.isFaviconsFetchingEnabled = true
                        model.onDismiss()
                    }
                } label: {
                    Text(UserText.fetchFaviconsOnboardingButtonTitle)
                }
                .buttonStyle(PrimaryButtonStyle())
                .frame(maxWidth: 360)

                Button {
                    withAnimation {
                        model.onDismiss()
                    }
                } label: {
                    Text(UserText.notNowButton)
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: 360)
            }
            .padding(.init(top: 24, leading: 24, bottom: 0, trailing: 24))
        }
    }
}
