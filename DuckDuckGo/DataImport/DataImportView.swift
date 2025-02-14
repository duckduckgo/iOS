//
//  DataImportView.swift
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
import Core

struct DataImportView: View {

    @ObservedObject var viewModel: DataImportViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ImportOverview(viewModel: viewModel)

                switch viewModel.state.importScreen {
                case .bookmarks:
                    BookmarksInstructions(viewModel: viewModel)
                case .passwords:
                    PasswordFooterView()
                    PasswordsInstructions(viewModel: viewModel)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
        }
        .background(Rectangle()
            .foregroundColor(Color(designSystemColor: .background))
            .ignoresSafeArea())
    }

    private struct ImportOverview: View {
        @ObservedObject var viewModel: DataImportViewModel

        var body: some View {
            VStack(alignment: .center, spacing: 8) {
                viewModel.state.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 72)
                    .padding(.top, 24)

                Text(viewModel.state.title)
                    .daxTitle3()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Text(viewModel.state.subtitle)
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.horizontal)

                Button {
                    viewModel.selectFile()
                } label: {
                    if viewModel.isLoading {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                            .padding(.trailing, 8)
                            .foregroundStyle(Color(.white))
                    } else {
                        Text(viewModel.state.buttonTitle)
                    }
                }
                .buttonStyle(PrimaryButtonStyle(disabled: viewModel.isLoading))
                .frame(maxWidth: 360)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
            .padding(.horizontal, 8)
        }
    }

    private struct PasswordFooterView: View {
        var body: some View {
            (Text(Image(.lockSolid16)).baselineOffset(-1.0) + Text(" ") + Text(UserText.autofillLoginListSettingsFooterFallback))
                .daxFootnoteRegular()
                .foregroundColor(Color(.secondaryText).opacity(0.6))
                .padding(.trailing)
                .padding(.leading, 10)
                .padding(.top, 8)
        }
    }

    private struct BookmarksInstructions: View {
        var viewModel: DataImportViewModel

        var body: some View {

            HStack {
                Text(UserText.dataImportBookmarksInstructionHeader.uppercased())
                    .daxFootnoteRegular()
                    .foregroundColor(.secondary)
                    .padding(.leading, 24)

                Spacer()
            }
            .padding(.top, 24)

            StepByStepInstructions(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.top, 24)
        }
    }

    private struct PasswordsInstructions: View {
        var viewModel: DataImportViewModel

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text(UserText.dataImportPasswordsInstructionHeader.uppercased())
                        .daxFootnoteRegular()
                        .foregroundColor(.secondary)
                        .padding(.leading, 24)

                    Spacer()
                }
                .padding(.top, 24)

                ExportFromCell(viewModel: viewModel)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.top, 5)
                    .padding(.horizontal, 8)

                StepByStepInstructions(viewModel: viewModel)
                    .padding(.horizontal, 12)
                    .padding(.top, 24)
            }
        }
    }

    private struct ExportFromCell: View {
        @ObservedObject var viewModel: DataImportViewModel

        var body: some View {
            HStack {
                viewModel.state.icon
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(UserText.dataImportPasswordsInstructionSelector)
                    .daxBodyRegular()
                    .foregroundStyle(Color(designSystemColor: .textPrimary))

                Spacer()

                Picker("", selection: $viewModel.state.browser) {
                    ForEach(DataImportViewModel.BrowserInstructions.allCases) { browser in
                        Text(browser.displayName)
                            .daxBodyRegular()
                            .foregroundColor(Color(designSystemColor: .textSecondary))
                            .tag(browser)
                    }
                }
                .pickerStyle(.automatic)
                .accentColor(Color(designSystemColor: .textSecondary))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    private struct StepByStepInstructions: View {
        @ObservedObject var viewModel: DataImportViewModel

        var body: some View {
            VStack(alignment: .leading) {
                ForEach(DataImportViewModel.InstructionStep.allCases, id: \.self) { step in
                    Instruction(step: step.rawValue, instructionText: Text(step.attributedInstructions(for: viewModel.state)))
                }
            }
        }

        func attributedText(_ string: AttributedString) -> Text {
            return Text(string)
        }
    }

    private struct Instruction: View {
        var step: Int
        var instructionText: Text

        var body: some View {
            HStack(alignment: .top, spacing: 16) {
                NumberBadge(number: step)
                instructionText
                    .daxBodyRegular()
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.top, 6)
            }
            .padding(.leading, 8)
        }
    }

}
