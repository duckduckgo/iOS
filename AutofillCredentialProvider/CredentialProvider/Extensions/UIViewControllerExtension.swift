//
//  UIViewControllerExtension.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
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

extension UIViewController {

    public func installChildViewController(_ childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)

        childController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            childController.view.topAnchor.constraint(equalTo: view.topAnchor),
            childController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            childController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            childController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        childController.didMove(toParent: self)
    }

}
