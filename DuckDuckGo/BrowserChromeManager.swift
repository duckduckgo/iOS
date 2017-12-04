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

    var hidden = false
    var lastYOffset: CGFloat = 0

    init(delegate: BrowserChromeDelegate) {
        self.delegate = delegate
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let yDiff = scrollView.contentOffset.y - lastYOffset
        print("*** yDiff", yDiff)

        if abs(yDiff) > Constants.threshold {
            updateBars(yDiff > 0)
        }

    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        lastYOffset = scrollView.contentOffset.y
        print("***", #function, lastYOffset)
    }

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        if hidden {
            updateBars(false)
            return false
        }

        return true
    }

    func reset() {
        print("***", #function)
        lastYOffset = 0
        hidden = false
    }

    private func updateBars(_ shouldHide: Bool) {
        print("***", #function, shouldHide, hidden)
        guard shouldHide != hidden else { return }
        hidden = shouldHide
        delegate.setBarsHidden(shouldHide, animated: true)
    }

}
