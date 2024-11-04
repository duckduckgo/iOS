//
//  AddToDockPromoView.swift
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
import Lottie

struct AddToDockPromoView: View {
    private static let appIconFillKeyPath = "**.Backdrop.Fill 1.Color"

    private var model = AddToDockPromoViewModel()

    @State private var isAnimating = false

    var body: some View {
        LottieView(
            lottieFile: "add-to-dock-promo",
            isAnimating: $isAnimating,
            animationImageProvider: model,
            valueProvider: .init(
                provider: ColorValueProvider(model.color),
                keypath: AnimationKeypath(keypath: Self.appIconFillKeyPath)
            )
        )
        .onFirstAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    AddToDockPromoView()
}
