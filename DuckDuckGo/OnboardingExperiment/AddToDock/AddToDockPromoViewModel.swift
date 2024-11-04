//
//  AddToDockPromoViewModel.swift
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

import UIKit
import Lottie

final class AddToDockPromoViewModel {
    private static let imageName = "img_0.png"

    private let appIconManager: AppIconProviding

    var color: LottieColor {
        LottieColor(icon: appIconManager.appIcon)
    }

    init(appIconManager: AppIconProviding = AppIconManager.shared) {
        self.appIconManager = appIconManager
    }
}

extension AddToDockPromoViewModel: AnimationImageProvider {

    func imageForAsset(asset: Lottie.ImageAsset) -> CGImage? {
        asset.name == Self.imageName ? UIImage(resource: .addToDockGradient).cgImage : nil
    }

}

// MARK: - Helpers

private extension LottieColor {

    init(icon: AppIcon) {
        switch icon {
        case .red:
            self = LottieColor(r: 0.87, g: 0.34, b: 0.2, a: 1.0)
        case .yellow:
            self = LottieColor(r: 0.89, g: 0.64, b: 0.07, a: 1.0)
        case .green:
            self = LottieColor(r: 0.22, g: 0.62, b: 0.16, a: 1.0)
        case .blue:
            self = LottieColor(r: 0.22, g: 0.41, b: 0.94, a: 1.0)
        case .purple:
            self = LottieColor(r: 0.42, g: 0.31, b: 0.73, a: 1.0)
        case .black:
            self = LottieColor(r: 0, g: 0, b: 0, a: 1.0)
        }
    }

}
