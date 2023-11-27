//
//  BrowserChromeManager.swift
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

protocol BrowserChromeDelegate: AnyObject {

    func setBarsHidden(_ hidden: Bool, animated: Bool)
    func setNavigationBarHidden(_ hidden: Bool)
    
    func setBarsVisibility(_ percent: CGFloat, animated: Bool)
    
    var canHideBars: Bool { get }
    var isToolbarHidden: Bool { get }
    var toolbarHeight: CGFloat { get }
    var barsMaxHeight: CGFloat { get }

    var omniBar: OmniBar { get }
    var tabBarContainer: UIView { get }
}

class BrowserChromeManager: NSObject, UIScrollViewDelegate {

    struct Constants {
        static let dragThreshold: CGFloat = 30
        static let zoomThreshold: CGFloat = 0.1
        
        static let contentSizeKVOKey = "contentSize"
    }

    weak var delegate: BrowserChromeDelegate? {
        didSet {
            animator.delegate = delegate
        }
    }
    
    private let animator = BarsAnimator()
    
    private var observation: NSKeyValueObservation?

    private var dragging = false
    private var startZoomScale: CGFloat = 0
    
    func attach(to scrollView: UIScrollView) {
        detach()
        
        scrollView.delegate = self
        
        observation = scrollView.observe(\.contentSize, options: .new) { [weak self] scrollView, _ in
            self?.scrollViewDidResizeContent(scrollView)
        }
    }
    
    func detach() {
        observation?.invalidate()
        observation = nil
    }
    
    private func scrollViewDidResizeContent(_ scrollView: UIScrollView) {
        if !canHideBars(for: scrollView) && animator.barsState != .revealed {
            animator.revealBars(animated: true)
        }
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !scrollView.isZooming else { return }
        
        guard dragging else { return }
        guard canHideBars(for: scrollView) else {
            if animator.barsState != .revealed {
                animator.revealBars(animated: true)
            }
            return
        }

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
        
        animator.didFinishScrolling(in: scrollView, velocity: velocity.y)
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
    
    /// Bars should not be hidden in case ScrollView content is smaller than full (with bars hidden) viewport.
    private func canHideBars(for scrollView: UIScrollView) -> Bool {
        let heightAllowsHide = scrollView.bounds.height + (delegate?.barsMaxHeight ?? 0) < scrollView.contentSize.height
        return heightAllowsHide && (delegate?.canHideBars ?? true)
    }

    func reset() {
        animator.revealBars(animated: true)
    }
}

private extension UIScrollView {
    var fullyZoomedOut: Bool {
        return zoomScale <= minimumZoomScale
    }
}
