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
    static let springDamping: CGFloat = 0.9
    static let springVelocity: CGFloat = 0.5
}

final class RoundedPageSheetPresentationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
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

        UIView.animate(withDuration: AnimatorConstants.duration,
                       delay: 0,
                       usingSpringWithDamping: AnimatorConstants.springDamping,
                       initialSpringVelocity: AnimatorConstants.springVelocity,
                       options: .curveEaseInOut,
                       animations: {
            toView.alpha = 1
            contentView.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
class RoundedPageSheetDismissalAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private var animator: UIViewPropertyAnimator?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimatorConstants.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? RoundedPageSheetContainerViewController,
              let fromView = fromViewController.view,
              let contentView = fromViewController.contentViewController.view else { return }

        let fromBackgroundView = fromViewController.backgroundView
        let containerView = transitionContext.containerView

        UIView.animate(withDuration: AnimatorConstants.duration,
                       delay: 0,
                       usingSpringWithDamping: AnimatorConstants.springDamping,
                       initialSpringVelocity: AnimatorConstants.springVelocity,
                       options: .curveEaseInOut,
                       animations: {
            fromBackgroundView.alpha = 0
            contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        }, completion: { finished in
            fromView.removeFromSuperview()
            transitionContext.completeTransition(finished)
        })
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let existingAnimator = animator {
            return existingAnimator
        }

        guard let fromViewController = transitionContext.viewController(forKey: .from) as? RoundedPageSheetContainerViewController,
              let fromView = fromViewController.view,
              let contentView = fromViewController.contentViewController.view else {
            fatalError("Invalid view controller setup")
        }

        let containerView = transitionContext.containerView
        let fromBackgroundView = fromViewController.backgroundView

        let animator = UIViewPropertyAnimator(duration: AnimatorConstants.duration,
                                              dampingRatio: AnimatorConstants.springDamping) {
            fromBackgroundView.alpha = 0
            contentView.transform = CGAffineTransform(translationX: 0, y: containerView.bounds.height)
        }

        animator.addCompletion { position in
            switch position {
            case .end:
                fromView.removeFromSuperview()
                transitionContext.completeTransition(true)
            default:
                transitionContext.completeTransition(false)
            }
        }

        self.animator = animator
        return animator
    }
}
