//
//  LottieView.swift
//  DuckDuckGo
//
//  Copyright © 2022 DuckDuckGo. All rights reserved.
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
 
struct LottieView: UIViewRepresentable {
    
    struct LoopWithIntroTiming {
        let skipIntro: Bool
        let introStartFrame: AnimationFrameTime
        let introEndFrame: AnimationFrameTime
        let loopStartFrame: AnimationFrameTime
        let loopEndFrame: AnimationFrameTime
    }

    enum LoopMode {
        case mode(LottieLoopMode)
        case withIntro(LoopWithIntroTiming)
    }

    struct ValueProvider {
        let provider: AnyValueProvider
        let keypath: AnimationKeypath
    }

    let delay: TimeInterval
    var isAnimating: Binding<Bool>
    private let loopMode: LoopMode
    private let animationImageProvider: AnimationImageProvider?
    private let valueProvider: ValueProvider?

    let animationName: String
    let animation: LottieAnimation?
    let animationView = LottieAnimationView()

    init(
        lottieFile: String,
        delay: TimeInterval = 0,
        loopMode: LoopMode = .mode(.playOnce),
        isAnimating: Binding<Bool> = .constant(true),
        animationImageProvider: AnimationImageProvider? = nil,
        valueProvider: ValueProvider? = nil
    ) {
        self.animationName = lottieFile
        self.animation = LottieAnimation.named(lottieFile)
        self.delay = delay
        self.isAnimating = isAnimating
        self.loopMode = loopMode
        self.animationImageProvider = animationImageProvider
        self.valueProvider = valueProvider
    }

    func makeUIView(context: Context) -> some LottieAnimationView {
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = false
        if let animationImageProvider {
            animationView.imageProvider = animationImageProvider
        }
        if let valueProvider {
            animationView.setValueProvider(valueProvider.provider, keypath: valueProvider.keypath)
        }

        switch loopMode {
        case .mode(let lottieLoopMode): animationView.loopMode = lottieLoopMode
        case .withIntro: break
        }

        return animationView
    }
 
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if uiView.isAnimationPlaying, !isAnimating.wrappedValue {
            uiView.stop()
            return
        }

        // If the view is not animating and the progress is 0, apply an animation-specific hack.
        // The VPN startup animations have an issue with the initial frame that is introduced when backgrounding and foregrounding the app.
        // The issue can be reproduced using the official Lottie SwiftUI wrapped, so instead it is being worked around by resetting the animation
        // when appropriate.
        if !isAnimating.wrappedValue, uiView.currentProgress == 0 {
            if uiView.currentFrame == 0, self.animationName.hasPrefix("vpn-") {
                uiView.animation = nil
                uiView.animation = self.animation
            }
        }

        guard isAnimating.wrappedValue, !uiView.isAnimationPlaying else {
            return
        }

        if uiView.loopMode == .playOnce && uiView.currentProgress == 1 {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            switch loopMode {
            case .mode:
                uiView.play(completion: { _ in
                    self.isAnimating.wrappedValue = false
                })
            case .withIntro(let timing):
                if timing.skipIntro {
                    uiView.play(fromFrame: timing.loopStartFrame, toFrame: timing.loopEndFrame, loopMode: .loop)
                } else {
                    uiView.play(fromFrame: timing.introStartFrame, toFrame: timing.introEndFrame, loopMode: .playOnce) { _ in
                        uiView.play(fromFrame: timing.loopStartFrame, toFrame: timing.loopEndFrame, loopMode: .loop)
                    }
                }
            }
        }
    }
}
