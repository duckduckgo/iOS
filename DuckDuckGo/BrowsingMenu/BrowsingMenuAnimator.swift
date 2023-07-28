//
//  BrowsingMenuAnimator.swift
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

import UIKit
import Foundation

final class BrowsingMenuAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private enum Constants {
        static let appearAnimationDuration = 0.1
        static let dismissAnimationDuration = 0.2
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        switch (transitionContext?.viewController(forKey: .from), transitionContext?.viewController(forKey: .to)) {
        case is (MainViewController, BrowsingMenuViewController):
            return Constants.appearAnimationDuration
        case is (BrowsingMenuViewController, MainViewController):
            return Constants.dismissAnimationDuration
        default:
            return 0
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch (transitionContext.viewController(forKey: .from), transitionContext.viewController(forKey: .to)) {
        case (let fromViewController as MainViewController, let toViewController as BrowsingMenuViewController):
            animatePresentation(from: fromViewController, to: toViewController, with: transitionContext)
        case (let fromViewController as BrowsingMenuViewController, let toViewController as MainViewController):
            animateDismissal(from: fromViewController, to: toViewController, with: transitionContext)
        default:
            assertionFailure("Unexpected View Controllers")
        }
    }

    func animatePresentation(from fromViewController: MainViewController, to toViewController: BrowsingMenuViewController, with transitionContext: UIViewControllerContextTransitioning) {

        let fromSnapshot = fromViewController.view.snapshotView(afterScreenUpdates: false)

        toViewController.view.frame = transitionContext.containerView.bounds
        toViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        transitionContext.containerView.addSubview(toViewController.view)

        if let fromSnapshot {
            transitionContext.containerView.addSubview(fromSnapshot)
        }

        toViewController.bindConstraints(to: fromViewController.currentTab?.webView)
        toViewController.view.layoutIfNeeded()

        let snapshot = toViewController.menuView.snapshotView(afterScreenUpdates: true)
        if let snapshot {
            snapshot.frame = Self.menuOriginFrameForAnimation(for: toViewController)
            snapshot.alpha = 0
            toViewController.menuView.superview?.addSubview(snapshot)

            BrowsingMenuViewController.applyShadowTo(view: snapshot, for: ThemeManager.shared.currentTheme)
        }

        toViewController.menuView.isHidden = true

        UIView.animate(withDuration: Constants.appearAnimationDuration, delay: 0, options: .curveEaseOut) {
            fromSnapshot?.removeFromSuperview()
            snapshot?.frame = toViewController.menuView.frame
            snapshot?.alpha = 1
        } completion: { _ in
            snapshot?.removeFromSuperview()

            defer {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            guard !transitionContext.transitionWasCancelled else {
                toViewController.view.removeFromSuperview()
                return
            }

            toViewController.menuView.isHidden = false
            toViewController.flashScrollIndicatorsIfNeeded()
        }
    }

    func animateDismissal(from fromViewController: BrowsingMenuViewController, to toViewController: MainViewController, with transitionContext: UIViewControllerContextTransitioning) {

        let snapshot = fromViewController.menuView.snapshotView(afterScreenUpdates: false)
        if let snapshot = snapshot {
            snapshot.frame = fromViewController.menuView.frame
            BrowsingMenuViewController.applyShadowTo(view: snapshot, for: ThemeManager.shared.currentTheme)
            transitionContext.containerView.addSubview(snapshot)
        }

        fromViewController.view.isHidden = true

        if toViewController.homeController != nil {
            toViewController.presentedMenuButton.setState(.bookmarksImage, animated: true)
        } else {
            toViewController.presentedMenuButton.setState(.menuImage, animated: true)
        }

        UIView.animate(withDuration: Constants.dismissAnimationDuration, animations: {
            snapshot?.alpha = 0
            snapshot?.frame = Self.menuOriginFrameForAnimation(for: fromViewController)
        }, completion: { _ in
            snapshot?.removeFromSuperview()
            fromViewController.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    private class func menuOriginFrameForAnimation(for controller: BrowsingMenuViewController) -> CGRect {
        if AppWidthObserver.shared.isLargeWidth {
            let frame = controller.menuView.frame
            var rect = frame.offsetBy(dx: frame.width - 100, dy: 0)
            rect.size.width = 100
            rect.size.height = 100
            return rect
        } else {
            let frame = controller.menuView.frame
            var rect = frame.offsetBy(dx: frame.width - 100, dy: frame.height - 100)
            rect.size.width = 100
            rect.size.height = 100
            return rect
        }
    }

}
