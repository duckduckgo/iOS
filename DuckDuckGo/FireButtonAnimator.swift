//
//  FireButtonAnimator.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

enum FireButtonAnimationType: String, CaseIterable {
    case fireRising
    case waterSwirl
    case airstream
    case none
    
    var descriptionText: String {
        switch self {
        case .fireRising:
            return UserText.fireButtonAnimationFireRisingName
        case .waterSwirl:
            return UserText.fireButtonAnimationWaterSwirlName
        case .airstream:
            return UserText.fireButtonAnimationAirstreamName
        case .none:
            return UserText.fireButtonAnimationNoneName //TODO translations
        }
    }
    
    var animationView: AnimationView? {
        guard let fileName = fileName else {
            return nil
        }
        let animationView = AnimationView(name: fileName)
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFill
        return animationView
    }
    
    private var fileName: String? {
        switch self {
        case .fireRising:
            return "01_Fire_reallysmol"
        case .waterSwirl:
            return "02_really_smol"
        case .airstream:
            return "03_dividedByFour"
        case .none:
            return nil
        }
    }
}

//TODO link to settings (aka appuserdefaults)?
//yeah, probs, and make all not static and add preloading

class FireButtonAnimator {
    
    //static let view = animation(type: .fireRising)
    
    static func animate(type: FireButtonAnimationType, completion: @escaping () -> Void) {
        
        guard let window = UIApplication.shared.keyWindow,
              let animationView = type.animationView else {
            completion()
            return
        }
        
        animationView.frame = window.frame
        window.addSubview(animationView)
        
        animationView.play { _ in
            completion()
            
            animationView.removeFromSuperview()
        }
    }
}
