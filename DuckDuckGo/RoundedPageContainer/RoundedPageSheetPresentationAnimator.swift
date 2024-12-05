//
//  RoundedPageSheetPresentationAnimator.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

enum AnimatorConstants {
    static let duration: TimeInterval = 0.4
}

class RoundedPageSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimatorConstants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to) as? RoundedPageSheetContainerViewController,
              let toView = toViewController.view,
              let contentView = toViewController.contentViewController.view else { return }

        let containerView = transitionContext.containerView

        containerView.addSubview(toView)
        toView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.alpha = 1
            contentView.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}

class RoundedPageSheetDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimatorConstants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? RoundedPageSheetContainerViewController,
              let fromView = fromViewController.view,
              let contentView = fromViewController.contentViewController.view else { return }

        let containerView = transitionContext.containerView

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            fromView.alpha = 0
            contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        }, completion: { finished in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }
}
