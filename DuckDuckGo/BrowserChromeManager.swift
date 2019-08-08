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

class BarsAnimator {
    
    weak var delegate: BrowserChromeDelegate?
    
    private var barsState: State = .revealed
    
    //private var cumulativeDistance: CGFloat = 0.0
    
    private var transitionProgress: CGFloat = 0.0
    
    var draggingStartPosY: CGFloat = 0
    
    var transitionStartPosY: CGFloat = 0
    
    
    enum State: String {
        case revealed
        case transitioning
//        case transitioned
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
        
//        print("-> ratio: \(min(normalizedDistance / barsHeight, 1.0))")
        return min(normalizedDistance / barsHeight, 1.0)
    }
    
    func didScroll(in scrollView: UIScrollView) {
        
//        print("-----")
//        print("-> state: \(barsState.rawValue)")
//        print("-> progress: \(transitionProgress)")
//        print("-> startPos Drag: \(draggingStartPosY)")
//        print("-> startPos Trans: \(transitionStartPosY)")
//        print("-> offset: \(scrollView.contentOffset.y)")
        
        switch barsState {
        case .revealed:
            if scrollView.contentOffset.y > draggingStartPosY {
                transitionStartPosY = draggingStartPosY
                barsState = .transitioning
                
                let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
                delegate?.setBarsVisibility(1.0 - ratio, animated: false)
                transitionProgress = ratio
                
                var offset = scrollView.contentOffset
                offset.y = draggingStartPosY
                scrollView.contentOffset = offset
            }
            
        case .transitioning:
            let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
            
            if ratio == 1.0 {
                barsState = .hidden
            } else if ratio == 0 {
                barsState = .revealed
            }
            
            delegate?.setBarsVisibility(1.0 - ratio, animated: false)
            transitionProgress = ratio
            
            var offset = scrollView.contentOffset
            offset.y = transitionStartPosY
            scrollView.contentOffset = offset
            
//        case .transitioned:
//            abort()
//            if scrollView.contentOffset.y < transitionStartPosY {
//                barsState = .transitioning
//
//                let ratio = calculateTransitionRatio(for: scrollView.contentOffset.y)
//                delegate?.setBarsVisibility(1.0 - ratio, animated: false)
//                transitionProgress = ratio
//            }
            
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
        
//        print("-----")
    }
    
    func didFinishScrolling(velocity: CGFloat) {
        guard velocity >= 0 else {
            barsState = .revealed
            transitionProgress = 0
            delegate?.setBarsVisibility(1, animated: true)
            return
        }
        
        guard velocity == 0 else {
            barsState = .hidden
            transitionProgress = 1
            delegate?.setBarsVisibility(0, animated: true)
            return
        }
        
        switch barsState {
        case .revealed, .hidden:
            break
//        case .transitioned:
//            barsState = .hidden
        case .transitioning:
            
            //todo: animate to revealed/hidden
            if transitionProgress > 0.5 && transitionProgress < 1.0 {
                barsState = .hidden
                transitionProgress = 1.0
                
                delegate?.setBarsVisibility(0, animated: true)
            } else if transitionProgress > 0 && transitionProgress  <= 0.5 {
                barsState = .revealed
                transitionProgress = 0
                
                delegate?.setBarsVisibility(1, animated: true)
            }
        }
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
    
    let animator = BarsAnimator()

    var hidden = false
    var dragging = false
    
    //var draggingStartPosY: CGFloat = 0
    
    var currentOffset: CGFloat = 0
    
    var startZoomScale: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming else { return } //
        
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
            updateBars(shouldHide: false)
        } else if abs(scrollView.zoomScale - startZoomScale) > Constants.zoomThreshold {
            updateBars(shouldHide: true)
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
        
//        let isInBottomBounceArea = scrollView.contentOffset.y > scrollView.contentOffsetYAtBottom
//        let startedFromVeryBottom = abs(draggingStartPosY - scrollView.contentOffsetYAtBottom) < 1
        
//        if isInBottomBounceArea && startedFromVeryBottom {
//            updateBars(shouldHide: false)
//            // Fix for iPhone X issue: reaching bottom of the web page and then revealing
//            // bars by executing "bottom bounce" gesture, caused web view to re layout and
//            // cover bottom of the web page.
//            DispatchQueue.main.async { [weak scrollView] in
//                guard let scrollView = scrollView else { return }
//                scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffsetYAtBottom),
//                                            animated: true)
//            }
//        } else if velocity.y < 0 {
//            updateBars(shouldHide: false)
//        } else if velocity.y > 0 {
//            updateBars(shouldHide: true)
//        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if hidden {
            updateBars(shouldHide: false)
            return false
        }

        return true
    }
    
    /// Bars should not be hidden in case ScrollView content is smaller than viewport.
    private func canHideBars(for scrollView: UIScrollView) -> Bool {
        return hidden || scrollView.bounds.height < scrollView.contentSize.height
    }

    private func updateBars(shouldHide: Bool) {
        guard shouldHide != hidden else { return }
        hidden = shouldHide
        delegate?.setBarsHidden(shouldHide, animated: true)
    }

    func reset() {
        updateBars(shouldHide: false)
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
