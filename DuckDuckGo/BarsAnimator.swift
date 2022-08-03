//
//  BarsAnimator.swift
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

class BarsAnimator {

    weak var delegate: BrowserChromeDelegate?

    private(set) var barsState: State = .revealed
    private var transitionProgress: CGFloat = 0.0

    var draggingStartPosY: CGFloat = 0

    var transitionStartPosY: CGFloat = 0

    private var bottomRevealGestureState: BottomBounceRevealing = .possible
    private var combinedBarsHeight: CGFloat {
        guard let delegate = delegate else { return 0 }
        return delegate.toolbarHeight + delegate.omniBar.frame.height
    }

    enum State: String {
        case revealed
        case transitioning
        case hidden
    }

    enum BottomBounceRevealing: String {
        case possible
        case triggered
        case cancelled
    }

    func didStartScrolling(in scrollView: UIScrollView) {
        draggingStartPosY = scrollView.contentOffset.y
    }

    func didScroll(in scrollView: UIScrollView) {

        switch barsState {
        case .revealed:
            revealedAndScrolling(in: scrollView)

        case .transitioning:
            transitioningAndScrolling(in: scrollView)

        case .hidden:
            hiddenAndScrolling(in: scrollView)

        }
    }

    private func revealedAndScrolling(in scrollView: UIScrollView) {
        guard scrollView.contentOffset.y > draggingStartPosY else { return }
        guard scrollView.contentOffset.y < scrollView.contentOffsetYAtBottom - combinedBarsHeight else { return }
        guard bottomRevealGestureState != .triggered else { return }

        // In case view has been "caught" in the middle of the animation above the (0.0, 0.0) offset,
        // wait till user scrolls to the top before animating any transition.
        if draggingStartPosY < 0, scrollView.contentOffset.y <= 0 {
            return
        }

        transitionStartPosY = draggingStartPosY < 0 ? 0 : draggingStartPosY
        barsState = .transitioning

        let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
        delegate?.setBarsVisibility(1.0 - ratio, animated: false)
        transitionProgress = ratio

        var offset = scrollView.contentOffset
        offset.y = transitionStartPosY
        scrollView.contentOffset = offset
    }

    private func transitioningAndScrolling(in scrollView: UIScrollView) {
        let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)

        if ratio == 1.0 {
            barsState = .hidden
        } else if ratio == 0 {
            barsState = .revealed
        } else if transitionProgress == ratio {
            return
        }

        delegate?.setBarsVisibility(1.0 - ratio, animated: false)
        transitionProgress = ratio

        var offset = scrollView.contentOffset
        offset.y = transitionStartPosY
        scrollView.contentOffset = offset
    }

    private func hiddenAndScrolling(in scrollView: UIScrollView) {
        let startedDraggingAtBottom = draggingStartPosY >= scrollView.contentOffsetYAtBottom
        if startedDraggingAtBottom, bottomRevealGestureState == .possible {
            let isInBottomBounceArea = scrollView.contentOffset.y > scrollView.contentOffsetYAtBottom
            if isInBottomBounceArea {
                revealBars(animated: true)
                bottomRevealGestureState = .triggered
            } else {
                // If user starts scrolling up, invalidate the possible reverse (scroll down) gesture
                bottomRevealGestureState = .cancelled
            }
        }

        guard scrollView.contentOffset.y < 0 else { return }

        transitionStartPosY = 0
        barsState = .transitioning

        let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
        delegate?.setBarsVisibility(1.0 - ratio, animated: false)
        transitionProgress = ratio
    }

    private func calculateTransitionRatio(for contentOffset: CGFloat) -> CGFloat {
        let distance = contentOffset - transitionStartPosY
        let barsHeight = delegate?.barsMaxHeight ?? CGFloat.infinity

        let cumulativeDistance = (barsHeight * transitionProgress) + distance
        let normalizedDistance = max(cumulativeDistance, 0)

        return min(normalizedDistance / barsHeight, 1.0)
    }

    func didFinishScrolling(in scrollView: UIScrollView, velocity: CGFloat) {
        defer {
            bottomRevealGestureState = .possible
        }

        guard bottomRevealGestureState != .triggered else {
            return
        }

        guard velocity >= 0 else {
            revealBars(animated: true)
            return
        }

        let isAboveExtendedBottomBounceArea = scrollView.contentOffset.y < scrollView.contentOffsetYAtBottom - combinedBarsHeight
        guard barsState == .transitioning || isAboveExtendedBottomBounceArea else { return }

        guard velocity == 0 else {
            hideBars(animated: true)
            return
        }

        switch barsState {
        case .revealed, .hidden:
            break

        case .transitioning:
            if transitionProgress > 0.5 && transitionProgress < 1.0 {
                hideBars(animated: true)
            } else if transitionProgress > 0 && transitionProgress  <= 0.5 {
                revealBars(animated: true)
            }
        }
    }

    func revealBars(animated: Bool) {
        let alreadyRevealed = barsState == .revealed

        barsState = .revealed
        transitionProgress = 0

        delegate?.setBarsVisibility(1, animated: animated && !alreadyRevealed)
    }

    func hideBars(animated: Bool) {
        guard barsState != .hidden else { return }

        barsState = .hidden
        transitionProgress = 1.0

        delegate?.setBarsVisibility(0, animated: animated)
    }
}

private extension UIScrollView {
    /// Calculate Y-axis content offset corresponding to very bottom of the scroll area
    var contentOffsetYAtBottom: CGFloat {
        let yOffset = contentSize.height - bounds.height
        return yOffset - adjustedContentInset.top + adjustedContentInset.bottom
    }
}
