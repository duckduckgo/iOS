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
    
    private var contenBlockerViewController: ContentBlockerViewController!
    private var errorViewController: ContentBlockerErrorViewController?
    
    private(set) var domain: String!
    
    static func loadFromStoryboard(withContentBlocker contentBlocker: ContentBlocker, domain: String) -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ContentBlockerPopover
        controller.contentBlocker = contentBlocker
        controller.domain = domain
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    public func refresh() {
        guard contentBlocker.hasData else {
            attachErrorViewController()
            return
        }
        contenBlockerViewController.refresh()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ContentBlockerViewController {
            controller.domain = domain
            controller.contentBlocker = contentBlocker
            contenBlockerViewController = controller
        }
    }
    
    fileprivate func attachErrorViewController() {
        let controller = ContentBlockerErrorViewController.loadFromStoryboard(delegate: self)
        contenBlockerViewController.willMove(toParentViewController: nil)
        addChildViewController(controller)
        container.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        errorViewController = controller
    }
    
    fileprivate func displayContentBlockerViewController() {
        errorViewController?.willMove(toParentViewController: nil)
        addChildViewController(contenBlockerViewController)
        container.addSubview(contenBlockerViewController.view)
        errorViewController?.view.removeFromSuperview()
        errorViewController?.removeFromParentViewController()
        contenBlockerViewController?.didMove(toParentViewController: self)
    }
}

extension ContentBlockerPopover: ContentBlockerErrorDelegate {
    func errorWasResolved() {
        displayContentBlockerViewController()
    }
}
