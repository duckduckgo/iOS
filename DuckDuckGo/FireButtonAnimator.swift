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
    
    var animation: Animation? {
        guard let fileName = fileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Animation.self, from: data)
        } catch {
            return nil
        }
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
    private var animation: Animation?
    
    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        reloadPreloadedAnimation()
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFireButtonAnimationChange),
                                               name: AppUserDefaults.Notifications.currentFireButtonAnimationChange,
                                               object: nil)
    }
        
    func animate(transitionCompletion: @escaping () -> Void, completion: @escaping () -> Void) {
        
        guard let window = UIApplication.shared.keyWindow,
              let animation = animation,
              let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            transitionCompletion()
            completion()
            return
        }
        
        window.addSubview(snapshot)
        
        let animationView = AnimationView(animation: animation)
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFill
        animationView.respectAnimationFrameRate = false
        let animationSpeed = 1.3
        animationView.animationSpeed = CGFloat(animationSpeed)
        
        animationView.frame = window.frame
        window.addSubview(animationView)
        
        let duration = animationView.animation?.duration ?? 0
        let delay = duration * appSettings.currentFireButtonAnimation.transition / animationSpeed
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            snapshot.removeFromSuperview()
            transitionCompletion()
        }
        
        animationView.play { _ in
            animationView.removeFromSuperview()
            completion()
        }
    }
    
    @objc func onFireButtonAnimationChange() {
        reloadPreloadedAnimation()
    }
    
    private func reloadPreloadedAnimation() {
        animation = appSettings.currentFireButtonAnimation.animation
    }
}
