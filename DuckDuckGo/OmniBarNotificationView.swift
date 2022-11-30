//
//  OmniBarNotificationView.swift
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

import Foundation
import UIKit

protocol OmniBarNotificationAnimated: UIViewController {
    func startAnimation(_ completion: @escaping () -> Void)
}

final class OmniBarNotificationView: UIView {
    var animatedView: OmniBarNotificationAnimated?
    
    enum AnimationType {
        case cookiesManaged
    }
    
    func prepareAnimation(_ type: AnimationType) {
        removeAnimation()
        let viewToAnimate: OmniBarNotificationAnimated
        switch type {
        case .cookiesManaged:
            viewToAnimate = CookiesManagedViewController()
        }
        
        
        addSubview(viewToAnimate.view)
        animatedView = viewToAnimate
        setupConstraints()
    }
    
    func startAnimation(completion: @escaping () -> Void) {
         self.animatedView?.startAnimation(completion)
    }
    
    func removeAnimation() {
        animatedView?.view.removeFromSuperview()
    }
    
    private func setupConstraints() {
        guard let animatedView = animatedView else {
            return
        }

        animatedView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animatedView.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            animatedView.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            animatedView.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            animatedView.view.topAnchor.constraint(equalTo: topAnchor)
        ])
    }
    
}
