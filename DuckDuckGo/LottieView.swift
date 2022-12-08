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
 
    @Binding var isAnimating: Bool
        
    let animationView = AnimationView()
 
    func makeUIView(context: Context) -> some AnimationView {
        print("recreating view")
        
        animationView.animation = Animation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        animationView.clipsToBounds = false
        
        return animationView
    }
 
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if isAnimating {
            print("isAnimating !")
            uiView.play()
        } else {
            print("resetting !")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                uiView.stop()
            }
        }
    }

}
