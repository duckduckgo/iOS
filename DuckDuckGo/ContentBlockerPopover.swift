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
    weak var delegate: ContentBlockerSettingsChangeDelegate?
    
    fileprivate weak var contentBlocker: ContentBlocker!
    private var siteRating: SiteRating!
    
    private var contentBlockerViewController: ContentBlockerViewController?
    
    static func loadFromStoryboard(withDelegate delegate: ContentBlockerSettingsChangeDelegate?, contentBlocker: ContentBlocker, siteRating: SiteRating) -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlocker", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ContentBlockerPopover
        controller.delegate = delegate
        controller.contentBlocker = contentBlocker
        controller.siteRating = siteRating
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard contentBlocker.hasData else {
            attachErrorViewController()
            return
        }
        guard contentBlocker.enabled else {
            attachDisabledViewController()
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
    }
    
    fileprivate func attachDisabledViewController() {
        let controller = ContentBlockerDisabledViewController.loadFromStoryboard(withDelegate: self)
        addToContainer(controller: controller)
    }
    
    fileprivate func attachContentBlockerViewController() {
        guard let siteRating = siteRating else { return }
        let controller = ContentBlockerViewController.loadFromStoryboard(withDelegate: delegate, contentBlocker: contentBlocker, siteRating: siteRating)
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
    
    fileprivate func dismiss(viewController: UIViewController) {
        viewController.willMove(toParentViewController: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
}

extension ContentBlockerPopover: ContentBlockerErrorDelegate {
    func errorWasResolved(errorController: ContentBlockerErrorViewController) {
        dismiss(viewController: errorController)
        attachContentBlockerViewController()
    }
}

extension ContentBlockerPopover: ContentBlockerDisabledDelegate {
    func contentBlockerWasEnabled(disabledController: ContentBlockerDisabledViewController) {
        dismiss(viewController: disabledController)
        contentBlocker.enabled = true
        delegate?.contentBlockerSettingsDidChange()
        attachContentBlockerViewController()
    }
}

extension ContentBlockerPopover: ContentBlockerSettingsChangeDelegate {
    
    func contentBlockerSettingsDidChange() {
        delegate?.contentBlockerSettingsDidChange()
    }

}
