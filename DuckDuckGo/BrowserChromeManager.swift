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

protocol BrowserChromeDelegate: class {

    func setBarsHidden(_ hidden: Bool, animated: Bool)
    func setNavigationBarHidden(_ hidden: Bool)

    var isToolbarHidden: Bool { get }
    var omniBar: OmniBar! { get }
    var toolbarHeight: CGFloat { get }

}

class BrowserChromeManager: NSObject, UIScrollViewDelegate {

    struct Constants {
        static let threshold: CGFloat = 30
    }

    weak var delegate: BrowserChromeDelegate?

    var hidden = false
    var dragging = false
    var draggingStartPosY: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard dragging else { return }
        guard canHideBars(for: scrollView) else { return }
        
        let isInBottomBounceArea = scrollView.contentOffset.y > scrollView.contentOffsetYAtBottom
        guard isInBottomBounceArea == false else { return }

        if scrollView.contentOffset.y - draggingStartPosY > Constants.threshold {
            updateBars(true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
        draggingStartPosY = scrollView.contentOffset.y
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard canHideBars(for: scrollView) else { return }
        
        let isInBottomBounceArea = scrollView.contentOffset.y > scrollView.contentOffsetYAtBottom
        let startedFromVeryBottom = abs(draggingStartPosY - scrollView.contentOffsetYAtBottom) < 1
        
        if isInBottomBounceArea && startedFromVeryBottom {
            updateBars(false)
        } else if velocity.y < 0 {
            updateBars(false)
        } else if velocity.y > 0 {
            updateBars(true)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if hidden {
            updateBars(false)
            return false
        }

        return true
    }
    
    /// Bars should not be hidden in case ScrollView content is smaller than viewport.
    private func canHideBars(for scrollView: UIScrollView) -> Bool {
        return scrollView.bounds.height < scrollView.contentSize.height
    }

    private func updateBars(_ shouldHide: Bool) {
        guard shouldHide != hidden else { return }
        hidden = shouldHide
        delegate?.setBarsHidden(shouldHide, animated: true)
    }

    func reset() {
        updateBars(false)
        draggingStartPosY = 0
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
}
