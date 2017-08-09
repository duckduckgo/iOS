//
//  ContentBlockerPopover.swift
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
import SafariServices
import Core

class ContentBlockerPopover: UIViewController {
    
    @IBOutlet weak var container: UIView!
    
    private weak var contentBlocker: ContentBlocker!
    
    private var contentBlockerViewController: ContentBlockerViewController?
    private var errorViewController: ContentBlockerErrorViewController?
    
    private(set) var https: Bool!
    private(set) var domain: String!
    
    static func loadFromStoryboard(withContentBlocker contentBlocker: ContentBlocker, https: Bool, domain: String) -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ContentBlockerPopover
        controller.contentBlocker = contentBlocker
        controller.https = https
        controller.domain = domain
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard contentBlocker.hasData else {
            attachErrorViewController()
            return
        }
        attachContentBlockerViewController()
    }
    
    func refresh() {
        contentBlockerViewController?.refresh()
    }

    fileprivate func attachErrorViewController() {
        let controller = ContentBlockerErrorViewController.loadFromStoryboard(delegate: self)
        addToContainer(controller: controller)
        errorViewController = controller
    }
    
    fileprivate func attachContentBlockerViewController() {
        let controller = ContentBlockerViewController.loadFromStoryboard(withContentBlocker: contentBlocker, https: https, domain: domain)
        addToContainer(controller: controller)
        contentBlockerViewController = controller
    }
    
    fileprivate func addToContainer(controller: UIViewController) {
        controller.view.frame = container.frame
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addChildViewController(controller)
        container.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }
    
    fileprivate func dismissError() {
        errorViewController?.willMove(toParentViewController: nil)
        errorViewController?.view.removeFromSuperview()
        errorViewController?.removeFromParentViewController()
    }
}

extension ContentBlockerPopover: ContentBlockerErrorDelegate {
    func errorWasResolved() {
        dismissError()
        attachContentBlockerViewController()
    }
}
