//
//  ImportPasswordsView.swift
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

struct ImportPasswordsView: View {
    
    var viewModel: ImportPasswordsViewModel
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                ImportOverview(viewModel: viewModel)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
                    .padding(.horizontal, 8)
                
                (Text(Image(.lockSolid16)).baselineOffset(-1.0) + Text(" ") + Text(UserText.autofillLoginListSettingsFooterFallback))
                    .daxFootnoteRegular()
                    .foregroundColor(Color(.secondaryText).opacity(0.6))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                
                Divider()
                    .padding(.vertical, 16)
                
                StepByStepInstructions(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                
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
        
        var viewModel: ImportPasswordsViewModel
        
        @State private var navigate = false
        
        var body: some View {
            
            VStack(alignment: .center, spacing: 8) {
                
                Image(.passwordsImport128)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 72)
                    .padding(.top, 24)
                
                Text(UserText.autofillImportPasswordsTitle)
                    .daxTitle3()
                    .multilineTextAlignment(.center)
                
                Text(UserText.autofillImportPasswordsSubtitle)
                    .daxBodyRegular()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(designSystemColor: .textSecondary))
                    .padding(.horizontal)
                
                Button {
                    viewModel.selectFile()
                } label: {
                    Text(UserText.autofillImportPasswordsInstructionsButton)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 24)
            
        }
    }
    
    private struct StepByStepInstructions: View {
        var viewModel: ImportPasswordsViewModel
        
        var body: some View {
            
            VStack(alignment: .leading) {
                Text(UserText.autofillImportPasswordsInstructionsTitle)
                    .daxHeadline()
                    .foregroundColor(Color(designSystemColor: .textPrimary))
                    .padding(.bottom, 12)
                
                ForEach(ImportPasswordsViewModel.InstructionStep.allCases, id: \.self) { step in
                    Instruction(step: step.rawValue, instructionText: attributedText(viewModel.attributedInstructionsForStep(step)))
                }
            }
            
        }
        
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
            .padding(.leading, 8)
            
        }
    }
}

#Preview {
    ImportPasswordsView(viewModel: ImportPasswordsViewModel())
}
