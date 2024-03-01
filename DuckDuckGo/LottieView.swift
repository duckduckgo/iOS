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
        let introStartFrame: AnimationFrameTime
        let introEndFrame: AnimationFrameTime
        let loopStartFrame: AnimationFrameTime
        let loopEndFrame: AnimationFrameTime
    }

    enum LoopMode {
        case mode(LottieLoopMode)
        case withIntro(LoopWithIntroTiming)
    }

    let lottieFile: String
    let delay: TimeInterval
    var isAnimating: Binding<Bool>
    private let loopMode: LoopMode

    let animationView = AnimationView()
    
    init(lottieFile: String, delay: TimeInterval = 0, loopMode: LoopMode = .mode(.playOnce), isAnimating: Binding<Bool> = .constant(true)) {
        self.lottieFile = lottieFile
        self.delay = delay
        self.isAnimating = isAnimating
        self.loopMode = loopMode
    }

    func makeUIView(context: Context) -> some AnimationView {
        animationView.animation = Animation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = false

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

        guard isAnimating.wrappedValue, !uiView.isAnimationPlaying else { return }
        
        if uiView.loopMode == .playOnce && uiView.currentProgress == 1 { return }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            switch loopMode {
            case .mode:
                uiView.play(completion: { _ in
                    self.isAnimating.wrappedValue = false
                })
            case .withIntro(let timing):
                uiView.play(fromFrame: timing.introStartFrame, toFrame: timing.introEndFrame, loopMode: .playOnce) { _ in
                    uiView.play(fromFrame: timing.loopStartFrame, toFrame: timing.loopEndFrame, loopMode: .loop)
                }
            }
        }
    }
}
