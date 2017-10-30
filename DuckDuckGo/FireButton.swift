//
//  FireButton.swift
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

class FireButton: UIView, NibLoading {

    typealias OnCilckHandler = () -> Void

    var onClickHandler: OnCilckHandler!

    @IBAction func onClick() {
        onClickHandler()
    }

    static func loadFromNib(_ onClickHandler:@escaping OnCilckHandler) -> FireButton {
        let view = FireButton.load(nibName: "FireButton") as FireButton
        view.onClickHandler = onClickHandler
        return view
    }

}

extension UIToolbar {

    func addFireButton(_ onClickHandler:@escaping FireButton.OnCilckHandler) -> FireButton {
        let view = FireButton.loadFromNib(onClickHandler)

        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)

        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        ])

        return view
    }

}
