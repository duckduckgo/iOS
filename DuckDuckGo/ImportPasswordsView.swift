//
//  ImportPasswordsView.swift
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
import Core
import DuckUI

struct ImportPasswordsView: View {

    var viewModel: ImportPasswordsViewModel

    var body: some View {

        ScrollView {
            VStack(spacing: 0) {
                ImportOverview(viewModel: viewModel)
                    .padding(.horizontal, 16)

                Divider()
                    .padding(.vertical, 32)

                StepByStepInstructions(viewModel: viewModel)
                    .padding(.horizontal, 16)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)

        }
        .background(Rectangle()
            .foregroundColor(Color(designSystemColor: .background))
            .ignoresSafeArea())

    }

    private struct ImportOverview: View {

        var viewModel: ImportPasswordsViewModel

        @State private var navigate = false

        var body: some View {
            Image(.syncDesktopNew128)

            Text(UserText.autofillImportPasswordsTitle)
                .daxTitle2()
                .foregroundColor(Color(designSystemColor: .textPrimary))
                .padding(.top, 16)

            Text(UserText.autofillImportPasswordsSubtitle)
                .daxBodyRegular()
                .foregroundColor(Color(designSystemColor: .textSecondary))
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            Button {
                self.navigate = true
            } label: {
                Text(viewModel.getBrowserButtonTitle)
                    .frame(width: viewModel.maxButtonWidth())
            }
            .buttonStyle(PrimaryButtonStyle(fullWidth: false))
            .padding(.top, 24)

            Button {
                viewModel.openSync()
            } label: {
                Text(viewModel.syncButtonTitle)
                    .frame(width: viewModel.maxButtonWidth())
            }
            .buttonStyle(SecondaryFillButtonStyle(fullWidth: false))
            .padding(.top, 8)

            NavigationLink(destination: DesktopDownloadView(viewModel: .init(platform: .desktop)), isActive: $navigate) {
                EmptyView()
            }

        }
    }

    private struct StepByStepInstructions: View {
        var viewModel: ImportPasswordsViewModel

        var body: some View {

            VStack(alignment: .leading) {
                Text(UserText.autofillImportPasswordsInstructionsTitle)
                    .daxHeadline()
                    .foregroundColor(Color(designSystemColor: .textPrimary))

                ForEach(ImportPasswordsViewModel.InstructionStep.allCases, id: \.self) { step in

                    if #available(iOS 15.0, *), step == .step2 || step == .step3 {
                        Instruction(step: step.rawValue, instructionText: attributedText(viewModel.attributedInstructionsForStep(step)))
                    } else {
                        Instruction(step: step.rawValue, instructionText: Text(viewModel.instructionsForStep(step)))
                    }
                }
            }

        }

        @available(iOS 15.0, *)
        func attributedText(_ string: AttributedString) -> Text {
            return Text(string)
        }

    }

    struct Instruction: View {
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

        }
    }

}

struct NumberBadge: View {
    var number: Int

    var body: some View {
        Text("\(number)")
            .daxHeadline()
            .padding(10)
            .background(
                Circle()
                    .fill(Color(.bulletListBackground))
            )
            .foregroundColor(Color(designSystemColor: .accent))
            .fixedSize()
    }
}

struct ImportPasswordsView_Previews: PreviewProvider {
    static var previews: some View {
        ImportPasswordsView(viewModel: ImportPasswordsViewModel()).preferredColorScheme(.light)
        ImportPasswordsView(viewModel: ImportPasswordsViewModel()).preferredColorScheme(.dark)
    }
}
