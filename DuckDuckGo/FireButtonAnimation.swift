//
//  FireButtonAnimation.swift
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
    
    var fileName: String? {
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
}

//TODO link to settings (aka appuserdefaults)

class FireButtonAnimation {

    static func animation(type: FireButtonAnimationType) -> AnimationView? {
        guard let fileName = type.fileName else {
            return nil
        }
        let animationView = AnimationView(name: fileName)
        animationView.loopMode = .playOnce
        return animationView
    }
    
    static let view = animation(type: .fireRising)
    
    static func animate(type: FireButtonAnimationType, completion: @escaping () -> Void) {
        
        guard let window = UIApplication.shared.keyWindow,
              let fileName = type.fileName else {
            completion()
            return
        }

        let animationView = AnimationView(name: fileName)
        animationView.loopMode = .playOnce
        animationView.contentMode = .scaleAspectFill//window.frame.width > animationView.bounds.width ? .scaleAspectFill : .center
        
        animationView.frame = window.frame
        window.addSubview(animationView)

//        anim.frame = window.frame
//        anim.transform.ty = anim.frame.size.height
//        window.addSubview(anim)
        
        animationView.play { _ in
            completion()
            
            animationView.removeFromSuperview()
        }

//        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
//            anim.transform.ty = -(anim.offset.constant * 2)
//        }, completion: { _ in
//            completion()
//        })
//
//        UIView.animate(withDuration: Constants.endAnimationDuration, delay: Constants.endDelayDuration, options: .curveEaseOut, animations: {
//            anim.alpha = 0
//        }, completion: { _ in
//            anim.removeFromSuperview()
//        })

    }
}

//class FireButtonAnimationController: UIViewController {
//    
//    let animationView: AnimationView = {
//        let animationView = AnimationView(name: FireButtonAnimationType.fire.rawValue)
//        animationView.loopMode = .playOnce
//        return animationView
//    }()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.addSubview(animationView)
//        
//        NSLayoutConstraint.activate([
//            animationView.topAnchor.constraint(equalTo: view.topAnchor),
//            animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//    
//        animationView.play()
//    }
//}
