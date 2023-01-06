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
    
    let lottieFile: String
    let delay: TimeInterval
    var isAnimating: Binding<Bool>
        
    let animationView = AnimationView()
    
    init(lottieFile: String, delay: TimeInterval = 0, isAnimating: Binding<Bool> = .constant(true)) {
        self.lottieFile = lottieFile
        self.delay = delay
        self.isAnimating = isAnimating
    }

    func makeUIView(context: Context) -> some AnimationView {
        animationView.animation = Animation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = false
        
        return animationView
    }
 
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard isAnimating.wrappedValue, !uiView.isAnimationPlaying else { return }
        
        if uiView.loopMode == .playOnce && uiView.currentProgress == 1 { return }
                
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            uiView.play(completion: { _ in
                self.isAnimating.wrappedValue = false
            })
        }
    }
}
