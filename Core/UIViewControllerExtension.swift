//
//  UIViewControllerExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIViewController {
    
    public func blur() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        view.addEqualWidthConstraint(subView: blurView)
        view.addEqualHeightConstraint(subView: blurView)
        view.backgroundColor = UIColor.clear
    }
    
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
        }
        present(controller, animated: true, completion: nil)
    }
}
