//
//  DissolveAnimatedTransitioning.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import Core

class DissolveAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    struct Constants {
        static let duration = 0.25
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.containerView
        fromView.backgroundColor = UIColor.clear
        fromView.alpha = 1

        UIView.animate(withDuration: Constants.duration, animations: {
            fromView.alpha = 0.0
        }, completion: { (_: Bool) in
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }
}
