//
//  OnboardingContainerView.swift
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

struct OnboardingButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity, minHeight: Const.Size.buttonHeight, maxHeight: Const.Size.buttonHeight)
            .background(configuration.isPressed ? Color.blue70 : Color(designSystemColor: .accent))
            .cornerRadius(Const.Size.cornerRadius)
    }
}

struct OnboardingContainerView: View {
    
    let viewModels: [OnboardingStepViewModel]
    let enableAppTP: () -> Void
    
    @State var currentModel: Int = 0
    
    func nextModel() {
        withAnimation {
            currentModel += 1
        }
    }
    
    func finishOnboarding() {
        enableAppTP()
    }
    
    func learnMoreTapped() {
        
    }
    
    var body: some View {
        VStack {
            let currentViewModel = viewModels[currentModel]
            OnboardingStepView(viewModel: currentViewModel)
            
            Spacer()
            
            Button(action: {
                if currentViewModel != viewModels.last {
                    nextModel()
                } else {
                    finishOnboarding()
                }
            }, label: {
                Text(currentViewModel.primaryButtonTitle)
                    .font(Font(uiFont: Const.Font.buttonFont))
                    .foregroundColor(Color.buttonLabelColor)
            })
            .buttonStyle(OnboardingButtonStyle())
            .padding(.bottom, Const.Size.buttonPadding)
        }
        .padding()
        .background(Color(designSystemColor: .surface))
        .ignoresSafeArea()
    }
}

private enum Const {
    enum Font {
        static let titleFont = UIFont.boldAppFont(ofSize: 28)
        static let paragraphFont = UIFont.appFont(ofSize: 16)
        static let buttonFont = UIFont.boldAppFont(ofSize: 15)
    }
    
    enum Size {
        static let buttonPadding: CGFloat = 24
        static let cornerRadius: CGFloat = 8
        static let buttonHeight: CGFloat = 50
    }
}

private extension Color {
    static let fontColor = Color("AppTPDomainColor")
    static let buttonLabelColor = Color("AppTPBreakageButtonLabel")
    static let disabledButton = Color("AppTPBreakageButtonDisabled")
    static let disabledButtonLabel = Color("AppTPBreakageButtonLabelDisabled")
}

struct OnboardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingContainerView(
                viewModels: OnboardingStepViewModel.onboardingData,
                enableAppTP: {}
            )
        }
    }
}
