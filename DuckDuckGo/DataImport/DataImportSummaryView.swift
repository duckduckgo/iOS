//
//  DataImportSummaryView.swift
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

struct DataImportSummaryView: View {

    @ObservedObject var viewModel: DataImportSummaryViewModel

    @State private var isAnimating = false

    var body: some View {

        VStack {
            ScrollView {
                VStack(spacing: 0) {
                    AnimationView(isAnimating: $isAnimating)

                    Text(UserText.dataImportSummaryTitle)
                        .daxTitle1()
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)

                    if viewModel.isAllSuccessful() {
                        SuccessContainer(
                            passwordsSuccessCount: viewModel.passwordsSummary?.successful ?? 0,
                            bookmarksSuccessCount: viewModel.bookmarksSummary?.successful ?? 0
                        )
                    } else {
                        if let passwordsSummary = viewModel.passwordsSummary {
                            Text(UserText.dataImportSummaryPasswordsSubtitle)
                                .daxSubheadRegular()
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(designSystemColor: .textSecondary))
                                .padding(.horizontal)
                                .padding(.top, 8)

                            StatsContainer(
                                successString: UserText.dataImportSummaryPasswordsSuccess,
                                successCount: passwordsSummary.successful,
                                failureCount: passwordsSummary.failed,
                                duplicatesCount: passwordsSummary.duplicate
                            )
                            .padding(.top, 28)
                        }

                        if let bookmarksSummary = viewModel.bookmarksSummary {
                            StatsContainer(
                                successString: UserText.dataImportSummaryBookmarksSuccess,
                                successCount: bookmarksSummary.successful,
                                failureCount: bookmarksSummary.failed,
                                duplicatesCount: bookmarksSummary.duplicate
                            )
                            .padding(.top, 28)
                        }
                    }
                }
            }
            .frame(maxWidth: 360)


            Spacer()

            VStack {
                Button {
                    viewModel.dismiss()
                } label: {
                    Text(UserText.dataImportSummaryDone)
                }
                .buttonStyle(PrimaryButtonStyle())

                if !viewModel.syncIsActive {
                    Button {
                        viewModel.launchSync()
                    } label: {
                        VStack {
                            Text(viewModel.syncButtonTitle)
                                .lineLimit(nil)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .buttonStyle(GhostButtonStyle())
                }
            }
            .frame(maxWidth: 360)
            .padding(.top, 16)
            .padding(.bottom, 36)

        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
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

    private struct AnimationView: View {
        @Binding var isAnimating: Bool

        var body: some View {
            LottieView(
                lottieFile: "burst-blob-passwords",
                isAnimating: $isAnimating
            )
            .frame(width: 200, height: 128)
            .padding(.top, 64)
        }
    }


    private struct SuccessContainer: View {
        var passwordsSuccessCount: Int
        var bookmarksSuccessCount: Int

        var body: some View {
            Text(UserText.dataImportSummaryPasswordsSubtitle)
                .daxSubheadRegular()
                .multilineTextAlignment(.center)
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 28)

            VStack(spacing: 12) {
                StatRow(isSuccess: true,
                        label: UserText.dataImportSummaryPasswordsSuccess,
                        count: passwordsSuccessCount,
                        showSeparator: true)

                StatRow(isSuccess: true,
                        label: UserText.dataImportSummaryBookmarksSuccess,
                        count: bookmarksSuccessCount,
                        showSeparator: false)
            }
            .padding(.vertical, 12)
            .background(Color(designSystemColor: .panel))
            .cornerRadius(10)
        }
    }

    private struct StatsContainer: View {
        var successString: String
        var successCount: Int
        var failureCount: Int
        var duplicatesCount: Int

        var body: some View {
            VStack(spacing: 12) {
                StatRow(isSuccess: true,
                        label: successString,
                        count: successCount,
                        showSeparator: failureCount != 0 || duplicatesCount != 0)

                if failureCount > 0 {
                    StatRow(isSuccess: false,
                            label: UserText.dataImportSummaryFailed,
                            count: failureCount,
                            showSeparator: duplicatesCount != 0)
                }

                if duplicatesCount > 0 {
                    StatRow(isSuccess: false,
                            label: UserText.dataImportSummaryDuplicates,
                            count: duplicatesCount,
                            showSeparator: false)
                }
            }
            .padding(.vertical, 12)
            .background(Color(designSystemColor: .panel))
            .cornerRadius(10)
        }
    }

    private struct StatRow: View {
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
