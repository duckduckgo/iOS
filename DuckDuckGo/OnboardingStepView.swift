//
//  OnboardingStepView.swift
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

struct OnboardingStepView: View {
    
    let viewModel: OnboardingStepViewModel
    
    var body: some View {
        VStack(spacing: Const.Size.stackSpacing) {
            Image(viewModel.pictogramName)
            
            Text(viewModel.title)
                .font(Font(uiFont: Const.Font.titleFont))
                .foregroundColor(Color.fontColor)
            
            viewModel.paragraph1
                .font(Font(uiFont: Const.Font.paragraphFont))
            
            viewModel.paragraph2
                .font(Font(uiFont: Const.Font.paragraphFont))
            
            if let auxButtonText = viewModel.auxButtonTitle {
                Button(action: {
                    
                }, label: {
                    Text(auxButtonText)
                        .font(Font(uiFont: Const.Font.paragraphFont))
                        .fontWeight(.bold)
                        .foregroundColor(Color(designSystemColor: .accent))
                })
            }
            
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, Const.Size.horizontalPadding)
        .padding(.top, Const.Size.topPadding)
        .background(Color(designSystemColor: .surface))
    }
}

private enum Const {
    enum Font {
        static let titleFont = UIFont.boldAppFont(ofSize: 28)
        static let paragraphFont = UIFont.appFont(ofSize: 16)
        static let buttonFont = UIFont.boldAppFont(ofSize: 15)
    }
    
    enum Size {
        static let stackSpacing: CGFloat = 24
        static let horizontalPadding: CGFloat = 32
        static let topPadding: CGFloat = 20
    }
}

private extension Color {
    static let fontColor = Color("AppTPDomainColor")
    static let buttonLabelColor = Color("AppTPBreakageButtonLabel")
    static let disabledButton = Color("AppTPBreakageButtonDisabled")
    static let disabledButtonLabel = Color("AppTPBreakageButtonLabelDisabled")
}

struct OnboardingStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingStepView(viewModel: OnboardingStepViewModel.onboardingData[0])
        }
    }
}
