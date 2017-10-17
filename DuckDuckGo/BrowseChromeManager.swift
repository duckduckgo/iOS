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

        static let threshold: CGFloat = 60

    }

    let delegate: BrowserChromeDelegate

    var dragging = false
    var hidden = false
    var lastOffset: CGPoint?
    var cumulative: CGFloat = 0

    init(delegate: BrowserChromeDelegate) {
        self.delegate = delegate
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard dragging else { return }

        if let lastOffset = lastOffset {

            let ydiff = lastOffset.y - scrollView.contentOffset.y

            if ydiff == 0 || (cumulative < 0 && ydiff > 0) || (cumulative > 0 && ydiff < 0) {
                cumulative = 0
            }

            cumulative += ydiff

            if abs(cumulative) > Constants.threshold {
                updateBars(ydiff < 0)
            }

        }

        lastOffset = scrollView.contentOffset
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        updateBars(false)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
        cumulative = 0
    }

    private func updateBars(_ shouldHide: Bool) {
        guard shouldHide != hidden else { return }
        hidden = shouldHide
        delegate.setBarsHidden(shouldHide, animated: true)
    }

}
