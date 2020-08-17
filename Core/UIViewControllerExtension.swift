//
//  UIViewControllerExtension.swift
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
import Core

extension UIViewController {
    
    var isSmall: Bool {
        return view.frame.height <= 568
    }
    
    var isPad: Bool {
        return traitCollection.horizontalSizeClass == .regular
    }

    @objc func buildActivities() -> [UIActivity] {
        return []
    }

    func overrideUserInterfaceStyle() {
        if #available(iOS 13.0, *) {
            if ThemeManager.shared.currentTheme.currentImageSet == .dark {
                overrideUserInterfaceStyle = .dark
            } else {
                overrideUserInterfaceStyle = .light
            }
        }
    }

    public func presentShareSheet(withItems activityItems: [Any], fromButtonItem buttonItem: UIBarButtonItem) {
        let activities = buildActivities()
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        shareController.overrideUserInterfaceStyle()
        present(controller: shareController, fromButtonItem: buttonItem)
    }

    public func presentShareSheet(withItems activityItems: [Any], fromView sourceView: UIView, atPoint point: Point? = nil) {
        let activities = buildActivities()
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        shareController.overrideUserInterfaceStyle()
        if #available(iOS 11.0, *) {
            shareController.excludedActivityTypes = [.markupAsPDF]
        }
        present(controller: shareController, fromView: sourceView, atPoint: point)
    }

    public func present(controller: UIViewController, fromButtonItem buttonItem: UIBarButtonItem) {
        if let popover = controller.popoverPresentationController {
            popover.barButtonItem = buttonItem
        }
        present(controller, animated: true, completion: nil)
    }

    public func present(controller: UIViewController, fromView sourceView: UIView, atPoint point: Point? = nil) {
        if let popover = controller.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = point != nil ? CGRect(x: point!.x, y: point!.y, width: 0, height: 0) : sourceView.bounds
        }
        present(controller, animated: true, completion: nil)
    }
}
