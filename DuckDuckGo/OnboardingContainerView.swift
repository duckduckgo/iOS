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
import DuckUI

#if APP_TRACKING_PROTECTION

struct OnboardingContainerView: View {
    
    let viewModels: [OnboardingStepViewModel]
    let enableAppTP: () -> Void
    
    @Binding var isLoading: Bool
    
    @State var currentModel: Int = 0
    
    init(viewModels: [OnboardingStepViewModel], enableAppTP: @escaping () -> Void, isLoading: Binding<Bool>) {
        self.viewModels = viewModels
        self.enableAppTP = enableAppTP
        self._isLoading = isLoading
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor(designSystemColor: .surface)
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
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
                            .tint(Color.white)
                    } else {
                        SwiftUI.ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                    }
                } else {
                    Text(currentViewModel.primaryButtonTitle)
                }
            })
            .buttonStyle(PrimaryButtonStyle())
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
