//
//  ViewHighlighter.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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
import Lottie

class ViewHighlighter {

    struct WeaklyHeldView {
        weak var view: UIView?
    }

    static var addedViews = [WeaklyHeldView]()

    static func showIn(_ window: UIWindow, focussedOnView view: UIView) {
        guard let center = view.superview?.convert(view.center, to: nil) else { return }
        let size = max(view.frame.width, view.frame.height) * 5.5

        let highlightView = LOTAnimationView(name: "view_highlight")
        highlightView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        highlightView.center = center
        highlightView.isUserInteractionEnabled = false
        window.addSubview(highlightView)

        highlightView.contentMode = .scaleToFill
        highlightView.loopAnimation = true
        highlightView.play()

        addedViews.append(WeaklyHeldView(view: highlightView))
    }

    static func hideAll() {
        addedViews.forEach { $0.view?.removeFromSuperview() }
        addedViews = []
    }

}
