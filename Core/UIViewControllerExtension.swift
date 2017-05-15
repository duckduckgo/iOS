//
//  UIViewControllerExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func presentShareSheet(withItems activityItems: [Any], fromButtonItem buttonItem: UIBarButtonItem) {
        let activities = [SaveBookmarkActivity()]
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        present(controller: shareController, fromButtonItem: buttonItem)
    }
    
    public func presentShareSheet(withItems activityItems: [Any], fromView sourceView: UIView) {
        let activities = [SaveBookmarkActivity()]
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)
        present(controller: shareController, fromView: sourceView)
    }

    public func present(controller: UIViewController, fromButtonItem buttonItem: UIBarButtonItem) {
        if let popover = controller.popoverPresentationController {
            popover.barButtonItem = buttonItem
        }
        present(controller, animated: true, completion: nil)
    }
    
    public func present(controller: UIViewController, fromView sourceView: UIView) {
        if let popover = controller.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds;
        }
        present(controller, animated: true, completion: nil)
    }
}
