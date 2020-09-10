//
//  UIViewToastExtension.swift
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
import Toast

private struct ViewConstants {
    static let marginBottom: CGFloat = 80
}

extension UIView {

    func showBottomToast(_ text: String, duration: TimeInterval = ToastManager.shared.duration) {
        let x = bounds.size.width / 2.0
        let y = bounds.size.height - ViewConstants.marginBottom
        
        var style = ToastManager.shared.style
        style.messageAlignment = .center
        makeToast(text, point: CGPoint(x: x, y: y), title: nil, image: nil, style: style, completion: nil)
    }

}
