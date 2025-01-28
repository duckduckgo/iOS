//
//  ImportPasswordsCompleteView.swift
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

import SwiftUI
import DesignResourcesKit
import DuckUI
import BrowserServicesKit
import Lottie

struct ImportPasswordsCompleteView: View {

    @ObservedObject var viewModel: ImportPasswordsCompleteViewModel

    @State private var isAnimating = false

    var body: some View {

        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    LottieView(
                        lottieFile: "burst-blob-passwords",
                        isAnimating: $isAnimating
                    )
                    .frame(width: 200, height: 128)
                    .padding(.top, 64)

                    Text(UserText.autofillImportPasswordsCompleteTitle)
                        .daxTitle1()
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    Text(UserText.autofillImportPasswordsCompleteSubtitle)
                        .daxSubheadRegular()
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(designSystemColor: .textSecondary))
                        .padding(.horizontal)
                        .padding(.top, 8)

                    StatsContainer(
                        successCount: viewModel.passwordsSummary?.successful ?? 0,
                        failureCount: viewModel.passwordsSummary?.failed ?? 0,
                        duplicatesCount: viewModel.passwordsSummary?.duplicate ?? 0
                    )
                    .padding(.top, 28)

                }
            }

            Spacer()

            Button {
                viewModel.dismiss()
            } label: {
                Text(UserText.autofillImportPasswordsCompleteDone)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 16)
            .padding(.bottom, 24)

        }
        .padding(.horizontal, 24)
        .background(Rectangle()
            .foregroundColor(Color(designSystemColor: .backgroundSheets))
            .ignoresSafeArea())
        .onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }

    }

    struct StatsContainer: View {
        var successCount: Int
        var failureCount: Int
        var duplicatesCount: Int

        var body: some View {
            VStack(spacing: 12) {
                StatRow(isSuccess: true,
                        label: UserText.autofillImportPasswordsCompleteSuccess,
                        count: successCount,
                        showSeparator: failureCount != 0 || duplicatesCount != 0)

                if failureCount > 0 {
                    StatRow(isSuccess: false,
                            label: UserText.autofillImportPasswordsCompleteFailed,
                            count: failureCount,
                            showSeparator: duplicatesCount != 0)
                }

                if duplicatesCount > 0 {
                    StatRow(isSuccess: false,
                            label: UserText.autofillImportPasswordsCompleteDuplicates,
                            count: duplicatesCount,
                            showSeparator: false)
                }
            }
            .padding(.vertical, 12)
            .background(Color(designSystemColor: .panel))
            .cornerRadius(10)
        }
    }

    struct StatRow: View {
        let isSuccess: Bool
        let label: String
        let count: Int
        let showSeparator: Bool

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 12) {
                        Image(isSuccess ? .checkRecolorable24 : .crossRecolorable24)
                        Text(label)
                            .daxBodyRegular()
                            .foregroundStyle(Color(designSystemColor: .textPrimary))
                    }
                    Spacer()
                    Text("\(count)")
                        .daxBodyRegular()
                        .foregroundStyle(Color(designSystemColor: .textSecondary))

                }
                .padding(.horizontal, 16)

                if showSeparator {
                    Divider()
                        .padding(.top, 12)
                        .padding(.leading, 54)
                        .padding(.trailing, 0)
                        .foregroundStyle(Color(designSystemColor: .lines))
                }
            }

        }
    }
}
