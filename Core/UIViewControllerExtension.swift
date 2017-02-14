//
//  UIViewControllerExtension.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 25/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

extension UIViewController {

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
