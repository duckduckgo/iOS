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
import DesignResourcesKit

#if APP_TRACKING_PROTECTION

struct OnboardingStepView: View {
    
    let viewModel: OnboardingStepViewModel
    
    var body: some View {
        VStack(spacing: Const.Size.stackSpacing) {
            Image(viewModel.pictogramName)
            
            Text(viewModel.title)
                .daxTitle1()
                .foregroundColor(Color.fontColor)
            
            viewModel.paragraph1
                .daxBodyRegular()
                .foregroundColor(Color.fontColor)
            
            viewModel.paragraph2
                .daxBodyRegular()
                .foregroundColor(Color.fontColor)
            
            if let auxButtonText = viewModel.auxButtonTitle {
                NavigationLink(destination: AppTPFAQView()) {
                    Text(auxButtonText)
                        .daxBodyBold()
                        .foregroundColor(Color(designSystemColor: .accent))
                }
            }
            
        }
        .multilineTextAlignment(.center)
        .padding(.top, Const.Size.topPadding)
        .background(Color(designSystemColor: .surface))
    }
}

private enum Const {
    enum Size {
        static let stackSpacing: CGFloat = 24
        static let horizontalPadding: CGFloat = 32
        static let topPadding: CGFloat = 20
    }
}

private extension Color {
    static let fontColor = Color("AppTPDomainColor")
}

struct OnboardingStepView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingStepView(viewModel: OnboardingStepViewModel.onboardingData[2])
        }
    }
}

#endif
