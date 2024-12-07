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

enum FireButtonAnimationType: String, CaseIterable, Identifiable, CustomStringConvertible {
    
    var description: String {
        return descriptionText
    }

    case fireRising
    case waterSwirl
    case airstream
    case none
    
    var id: String { self.rawValue }
    
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
    
    var composition: LottieAnimation? {
        guard let fileName = fileName else { return nil }
        return LottieAnimation.named(fileName, animationCache: DefaultAnimationCache.sharedCache)
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
    
    var endFrame: NSNumber {
        switch self {
        case .fireRising:
            return 21
        case .waterSwirl:
            return 24
        case .airstream:
            return 18
        case .none:
            return 0
        }
    }
}

class FireButtonAnimator {
    
    private let appSettings: AppSettings
    private var preLoadedComposition: LottieAnimation?

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        reloadPreLoadedComposition()
                
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onFireButtonAnimationChange),
                                               name: AppUserDefaults.Notifications.currentFireButtonAnimationChange,
                                               object: nil)
    }

    /// Shows the selected clearing animation while managing a screenshot of the screen in order to allow UI updates happen while the animation is running (e.g. tabs closing).
    ///
    /// To use this start clearing immediately in a separate task.  Wait for this task to finish and if cleaning is still happening then show the indeterminte progress.
    ///
    /// @param afterScreenUpdates Mainly provided for the preview in settings.  From the fire button we want the screen to be captured immediately.
    @MainActor
    func animate(afterScreenUpdates: Bool = false) async {
        print("***", #function, "IN")

        guard let window = UIApplication.shared.firstKeyWindow,
              let snapshot = window.snapshotView(afterScreenUpdates: afterScreenUpdates),
              let composition = preLoadedComposition else {
            return
        }

        window.addSubview(snapshot)

        let animationView = LottieAnimationView(animation: composition)
        let currentAnimation = appSettings.currentFireButtonAnimation
        let speed = currentAnimation.speed
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = CGFloat(speed)
        animationView.frame = window.frame
        window.addSubview(animationView)

        let duration = Double(composition.duration) / speed
        let delay = duration * currentAnimation.transition

        var animationFinished = false
        print("***", #function, " play IN")
        animationView.play(fromProgress: 0, toProgress: 1) { _ in
            animationFinished = true
            print("***", #function, " play OUT")
        }

        await transition(snapshot, withDelay: delay)

        while !animationFinished {
            await Task.yield() // Give the system chance to decide if something higher priority should run
            try? await Task.sleep(interval: 0.01) // Either way, wait a small amount of time for the animation to finish in case this is the highest priority task
        }

        animationView.removeFromSuperview()
        print("***", #function, "OUT")
    }

    func transition(_ snapshot: UIView, withDelay delay: TimeInterval) async {
        print("***", #function, "IN")
        do {
            try await Task.sleep(interval: delay)
        } catch {
            // TODO log this
        }
        await snapshot.removeFromSuperview()
        print("***", #function, "OUT")
    }

    func legacy_animate(onAnimationStart: @escaping () async -> Void, onTransitionCompleted: @escaping () async -> Void, completion: @escaping () async -> Void) {

        guard let window = UIApplication.shared.firstKeyWindow,
              let snapshot = window.snapshotView(afterScreenUpdates: false) else {
            Task { @MainActor in
                await onAnimationStart()
                await onTransitionCompleted()
                await completion()
            }
            return
        }
        
        guard let composition = preLoadedComposition else {
            Task { @MainActor in
                await onAnimationStart()
                await onTransitionCompleted()
                await completion()
            }
            return
        }
        
        window.addSubview(snapshot)
        
        let animationView = LottieAnimationView(animation: composition)
        let currentAnimation = appSettings.currentFireButtonAnimation
        let speed = currentAnimation.speed
        animationView.contentMode = .scaleAspectFill
        animationView.animationSpeed = CGFloat(speed)
        animationView.frame = window.frame
        window.addSubview(animationView)

        let duration = Double(composition.duration) / speed
        let delay = duration * currentAnimation.transition
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            snapshot.removeFromSuperview()
            Task { @MainActor in
                await onTransitionCompleted()
            }
        }
        
        animationView.play(fromProgress: 0, toProgress: 1) { [weak animationView] _ in
            animationView?.removeFromSuperview()
            Task { @MainActor in
                await completion()
            }
        }

        DispatchQueue.main.async {
            Task { @MainActor in
                await onAnimationStart()
            }
        }
    }
    
    @objc func onFireButtonAnimationChange() {
        reloadPreLoadedComposition()
    }
    
    private func reloadPreLoadedComposition() {
        preLoadedComposition = appSettings.currentFireButtonAnimation.composition
    }
}
