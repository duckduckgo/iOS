//
//  BrowserChromeDelegate.swift
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

import UIKit

private class BarsAnimator {
    
    weak var delegate: BrowserChromeDelegate?
    
    private(set) var barsState: State = .revealed
    private var transitionProgress: CGFloat = 0.0
    
    var draggingStartPosY: CGFloat = 0
    
    var transitionStartPosY: CGFloat = 0
    
    enum State: String {
        case revealed
        case transitioning
        case hidden
    }
    
    func didStartScrolling(in scrollView: UIScrollView) {
        draggingStartPosY = scrollView.contentOffset.y
    }
    
    func calculateTransitionRatio(for contentOffset: CGFloat) -> CGFloat {
        let distance = contentOffset - transitionStartPosY
        let barsHeight = delegate?.barsMaxHeight ?? CGFloat.infinity
        
        let cumulativeDistance = (barsHeight * transitionProgress) + distance
        let normalizedDistance = max(cumulativeDistance, 0)
        
        return min(normalizedDistance / barsHeight, 1.0)
    }
    
    func didScroll(in scrollView: UIScrollView) {

        switch barsState {
        case .revealed:
            if scrollView.contentOffset.y > draggingStartPosY {
                // In case view has been "caught" in the middle of the animation above the (0.0, 0.0) offset, wait till user scrolls to the top before animating any transition.
                if draggingStartPosY < 0, scrollView.contentOffset.y <= 0 {
                    break
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
            
        case .transitioning:
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
            
        case .hidden:
            if scrollView.contentOffset.y < 0 {
                transitionStartPosY = 0
                barsState = .transitioning
                
                let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
                delegate?.setBarsVisibility(1.0 - ratio, animated: false)
                transitionProgress = ratio
            }
            // if offset is 0 - reveal
        }
    }
    
    func didFinishScrolling(velocity: CGFloat) {
        guard velocity >= 0 else {
            revealBars(animated: true)
            return
        }
        
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
        guard barsState != .revealed else { return }
        
        barsState = .revealed
        transitionProgress = 0
        
        delegate?.setBarsVisibility(1, animated: animated)
    }
    
    func hideBars(animated: Bool) {
        guard barsState != .hidden else { return }
        
        barsState = .hidden
        transitionProgress = 1.0
        
        delegate?.setBarsVisibility(0, animated: animated)
    }
}
protocol BrowserChromeDelegate: class {

    func setBarsHidden(_ hidden: Bool, animated: Bool)
    
    // Nav search home renderer
    func setNavigationBarHidden(_ hidden: Bool)
    
    func setBarsVisibility(_ percent: CGFloat, animated: Bool)

    var isToolbarHidden: Bool { get }
    var omniBar: OmniBar! { get }
    var toolbarHeight: CGFloat { get }
    var barsMaxHeight: CGFloat { get }
}

class BrowserChromeManager: NSObject, UIScrollViewDelegate {

    struct Constants {
        static let dragThreshold: CGFloat = 30
        static let zoomThreshold: CGFloat = 0.1
    }

    weak var delegate: BrowserChromeDelegate? {
        didSet {
            animator.delegate = delegate
        }
    }
    
    private let animator = BarsAnimator()

    private var dragging = false
    private var startZoomScale: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming else { return }
        
        guard dragging else { return }
        guard canHideBars(for: scrollView) else { return }
        
        let isInBottomBounceArea = scrollView.contentOffset.y > scrollView.contentOffsetYAtBottom
        guard isInBottomBounceArea == false else { return }

        animator.didScroll(in: scrollView)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView.isTracking else { return }
        guard !scrollView.isZoomBouncing else { return }
        
        if scrollView.fullyZoomedOut {
            animator.revealBars(animated: true)
        } else if abs(scrollView.zoomScale - startZoomScale) > Constants.zoomThreshold {
            animator.hideBars(animated: true)
        }
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        startZoomScale = scrollView.zoomScale
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming else { return }
        dragging = true
        
        animator.didStartScrolling(in: scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard !scrollView.isZooming else { return }
        guard canHideBars(for: scrollView) else { return }
        
        animator.didFinishScrolling(velocity: velocity.y)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        switch animator.barsState {
        case .hidden:
            animator.revealBars(animated: true)
            return false
        default:
            return true
        }
    }
    
    /// Bars should not be hidden in case ScrollView content is smaller than viewport.
    private func canHideBars(for scrollView: UIScrollView) -> Bool {
        return scrollView.bounds.height < scrollView.contentSize.height
    }

    func reset() {
        animator.revealBars(animated: true)
    }
}

fileprivate extension UIScrollView {
    
    /// Calculate Y-axis content offset corresponding to very bottom of the scroll area
    var contentOffsetYAtBottom: CGFloat {
        let yOffset = contentSize.height - bounds.height - contentInset.top + contentInset.bottom
        if #available(iOS 11.0, *) {
            return yOffset - safeAreaInsets.top + safeAreaInsets.bottom
        } else {
            return yOffset
        }
    }
    
    var fullyZoomedOut: Bool {
        return zoomScale <= minimumZoomScale
    }
    
}
