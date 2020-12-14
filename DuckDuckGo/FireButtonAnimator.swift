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
            return UserText.fireButtonAnimationNoneName
        }
    }
    
    var animationView: LOTAnimationView? {
        guard let fileName = fileName else { return nil }
        let animationView = LOTAnimationView(name: fileName)
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = CGFloat(speed)
        return animationView
    }

    var transition: Double {
        switch self {
        case .fireRising:
            return 0.35
        case .waterSwirl:
            return 0.5
        case .airstream:
            return 0.5
        case .none:
            return 0
        }
    }
    
    var speed: Double {
        return 1.3
    }
    
    private var fileName: String? {
        switch self {
        case .fireRising:
            return "01_Fire_really_small"
        case .waterSwirl:
            return "02_Water_swirl_really_small"
        case .airstream:
            return "03_Airstream_divided_by_four"
        case .none:
            return nil
        }
    }
}

class FireButtonAnimator {
    
    private let appSettings: AppSettings
    private var animationView: LOTAnimationView?
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        reloadAnimationView()
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFireButtonAnimationChange),
                                               name: AppUserDefaults.Notifications.currentFireButtonAnimationChange,
                                               object: nil)
    }
        
    func animate(animationStartCompletion: @escaping () -> Void, transitionCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        
        guard let window = UIApplication.shared.keyWindow,
              let animationView = animationView,
              let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            transitionCompletion()
            completion()
            return
        }
        
        window.addSubview(snapshot)
        
        animationView.frame = window.frame
        window.addSubview(animationView)
        
        let currentAnimation = appSettings.currentFireButtonAnimation
        let duration = Double(animationView.animationDuration) / currentAnimation.speed
        let delay = duration * currentAnimation.transition
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            snapshot.removeFromSuperview()
            transitionCompletion()
        }
        
        animationView.play { _ in
            animationView.removeFromSuperview()
            completion()
        }

        DispatchQueue.main.async {
            animationStartCompletion()
        }
    }
    
    @objc func onFireButtonAnimationChange() {
        reloadAnimationView()
    }
    
    private func reloadAnimationView() {
        animationView = appSettings.currentFireButtonAnimation.animationView
    }
}
