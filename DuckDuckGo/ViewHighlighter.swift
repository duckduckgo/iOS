//
//  ViewHighlighter.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 01/10/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit
import Lottie

class ViewHighlighter {

    struct WeaklyHeldView {
        weak var view: UIView?
    }

    static var addedViews = [WeaklyHeldView]()

    static func showIn(_ window: UIWindow, focussedOnView view: UIView) {
        let size = max(view.frame.width, view.frame.height) * 3

        let highlightView = AnimationView(name: "view_highlight")
        highlightView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        highlightView.center = window.convert(view.center, from: view)
        highlightView.isUserInteractionEnabled = false
        window.addSubview(highlightView)

        highlightView.contentMode = .scaleToFill
        highlightView.loopMode = .loop
        highlightView.play()

        addedViews.append(WeaklyHeldView(view: highlightView))
    }

    static func hideAll() {
        addedViews.forEach { $0.view?.removeFromSuperview() }
        addedViews = []
    }

}
