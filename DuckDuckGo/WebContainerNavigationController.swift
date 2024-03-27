//
//  WebContainerNavigationController.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

import Core
import UIKit

class WebContainerNavigationController: UINavigationController {

    var url: URL?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let controller = viewControllers[0] as? WebContainerViewController else {
            fatalError("Root controller is not \(WebContainerViewController.self)")
        }

        controller.title = title
        controller.url = url
    }

    static func load(url: URL, withTitle title: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "WebContainer", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? WebContainerNavigationController else {
            fatalError("Initial view controller not \(WebContainerNavigationController.self)")
        }
        controller.url = url
        controller.title = title
        return controller
    }

}
