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
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    @objc func buildActivities() -> [UIActivity] {
        return []
    }

    func overrideUserInterfaceStyle() {
        if ThemeManager.shared.currentTheme.currentImageSet == .dark {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }

    public func presentShareSheet(withItems activityItems: [Any], fromButtonItem buttonItem: UIBarButtonItem, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let activities = buildActivities()
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        shareController.completionWithItemsHandler = completion
        shareController.overrideUserInterfaceStyle()
        present(controller: shareController, fromButtonItem: buttonItem)
    }

    public func presentShareSheet(withItems activityItems: [Any], fromView sourceView: UIView, atPoint point: Point? = nil, overrideInterfaceStyle: UIUserInterfaceStyle? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        let activities = buildActivities()
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        shareController.completionWithItemsHandler = completion
        if let overrideInterfaceStyle {
            shareController.overrideUserInterfaceStyle = overrideInterfaceStyle
        } else {
            shareController.overrideUserInterfaceStyle()
        }
        shareController.excludedActivityTypes = [.markupAsPDF]
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
    
    public func installChildViewController(_ childController: UIViewController) {
        addChild(childController)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.view.frame = view.bounds
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }
}

extension Core.Bookmark {

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        guard let url = url else {
            return ""
        }
        return url.removingInternalSearchParameters()
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        guard let url = url else { return nil }
        return url.removingInternalSearchParameters()
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if let title = title, activityType == .mail {
            return title
        } else {
            return ""
        }
    }
}

// Unfortuntely required to make methods available to objc
extension Core.BookmarkManagedObject: UIActivityItemSource {
    
    @objc public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        (self as Bookmark).activityViewControllerPlaceholderItem(activityViewController)
    }

    @objc public func activityViewController(_ activityViewController: UIActivityViewController,
                                             itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        (self as Bookmark).activityViewController(activityViewController, itemForActivityType: activityType)
    }

    @objc public func activityViewController(_ activityViewController: UIActivityViewController,
                                             subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        (self as Bookmark).activityViewController(activityViewController, subjectForActivityType: activityType)
    }
}

extension Core.Link: UIActivityItemSource {

    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let localFileURL = localFileURL {
            return localFileURL
        }
        return url.removingInternalSearchParameters()
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        // We don't want to save localPath to favorites or bookmarks
        if let localFileURL = localFileURL,
           activityType != .saveBookmarkInDuckDuckGo,
           activityType != .saveFavoriteInDuckDuckGo {
        
            return localFileURL
        }
        return url.removingInternalSearchParameters()
    }

    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        if let title = title, activityType == .mail {
            return title
        } else {
            return ""
        }
    }
}
