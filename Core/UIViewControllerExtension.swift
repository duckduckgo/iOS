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
    
    public func presentShareSheetFromButton(activityItems: [Any], buttonItem: UIBarButtonItem) {
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let popover = shareController.popoverPresentationController {
            popover.barButtonItem = buttonItem
        }
        present(shareController, animated: true, completion: nil)
    }
    
    public func presentShareSheetFromView(activityItems: [Any], sourceView: UIView) {
        let shareController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let popover = shareController.popoverPresentationController {
            popover.sourceView = sourceView
        }
        present(shareController, animated: true, completion: nil)
    }
}
