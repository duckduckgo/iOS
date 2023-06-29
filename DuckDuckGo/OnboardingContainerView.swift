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

#if APP_TRACKING_PROTECTION

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
    
    @Binding var isLoading: Bool
    
    @State var currentModel: Int = 0
    
    func nextModel() {
        withAnimation {
            currentModel += 1
        }
    }
    
    func finishOnboarding() {
        enableAppTP()
    }
    
    private var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        VStack {
            let currentViewModel = viewModels[currentModel]
            OnboardingStepView(viewModel: currentViewModel)
                .padding(
                    .horizontal,
                    isPad ? Const.Size.horizontalStackPaddingPad : Const.Size.horizontalStackPadding
                )
            
            Spacer()
            
            Button(action: {
                if currentViewModel != viewModels.last {
                    nextModel()
                } else {
                    finishOnboarding()
                }
            }, label: {
                if isLoading {
                    if #available(iOS 16, *) {
                        SwiftUI.ProgressView()
                            .tint(Color.buttonLabelColor)
                    } else {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.buttonLabelColor))
                    }
                } else {
                    Text(currentViewModel.primaryButtonTitle)
                        .font(Font(uiFont: Const.Font.buttonFont))
                        .foregroundColor(Color.buttonLabelColor)
                }
            })
            .buttonStyle(OnboardingButtonStyle())
            .padding(.bottom, Const.Size.buttonPadding)
            .padding(
                .horizontal,
                isPad ? Const.Size.buttonHPaddingPad : Const.Size.buttonHPadding
            )
        }
        .padding(.vertical)
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
        static let horizontalStackPadding: CGFloat = 32
        static let horizontalStackPaddingPad: CGFloat = 140
        static let buttonPadding: CGFloat = 24
        static let buttonHPadding: CGFloat = 24
        static let buttonHPaddingPad: CGFloat = 92
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
                enableAppTP: {},
                isLoading: .constant(false)
            )
        }
        .previewDevice("iPhone 14 Pro Max")
        
        Color.clear
            .sheet(isPresented: .constant(true)) {
                OnboardingContainerView(
                    viewModels: OnboardingStepViewModel.onboardingData,
                    enableAppTP: {},
                    isLoading: .constant(false)
                )
            }
            .previewDevice("iPad Pro (11 inch)")
    }
}

#endif
