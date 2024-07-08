//
//  OnboardingTextStyles.swift
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

enum OnboardingStyles {}

extension OnboardingStyles {

    struct TitleStyle: ViewModifier {

        let fontSize: CGFloat

        func body(content: Content) -> some View {
            let view = content
                .font(.system(size: fontSize, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            if #available(iOS 16, *) {
                return view.kerning(0.38)
            } else {
                return view
            }
        }

    }

}

extension View {

    func onboardingTitleStyle(fontSize: CGFloat) -> some View {
        modifier(OnboardingStyles.TitleStyle(fontSize: fontSize))
    }
    
}
