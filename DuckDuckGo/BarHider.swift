//
//  BarHiding.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 14/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

protocol BarHidingDelegate: class {

    func setBarsHidden(_ hidden: Bool)
    func setNavigationBarHidden(_ hidden: Bool)
    var omniBar: OmniBar! { get }
    var isToolbarHidden: Bool { get }

}

class BarHider: NSObject, UIScrollViewDelegate {

    struct Constants {

        static let threshold: CGFloat = 60

    }

    let delegate: BarHidingDelegate

    var dragging = false
    var hidden = false
    var lastOffset: CGPoint?
    var cumulative: CGFloat = 0

    init(delegate: BarHidingDelegate) {
        self.delegate = delegate
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard dragging else { return }

        if let lastOffset = lastOffset {

            let ydiff = lastOffset.y - scrollView.contentOffset.y
            // print("***", "ydiff", ydiff)

            if ydiff == 0 || (cumulative < 0 && ydiff > 0) || (cumulative > 0 && ydiff < 0) {
                cumulative = 0
            }

            cumulative += ydiff
            // print("***", "cumulative", cumulative)

            if abs(cumulative) > Constants.threshold {
                let shouldHide = ydiff < 0
                if shouldHide != hidden {
                    delegate.setBarsHidden(shouldHide)
                    hidden = shouldHide
                }
            }

        }

        lastOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        dragging = false
        cumulative = 0
        print("***", #function)
    }

}
