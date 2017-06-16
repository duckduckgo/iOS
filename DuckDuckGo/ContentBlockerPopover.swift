//
//  ContentBlockerPopover.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 15/06/2017.
//  Copyright (c) 2015 Edinburgh International Science Festival. All rights reserved.
//

import UIKit

class ContentBlockerPopover: UIViewController {
    
    @IBOutlet weak var trackerCountLabel: UILabel!
    
    static func loadFromStoryboard() -> ContentBlockerPopover {
        let storyboard = UIStoryboard.init(name: "ContentBlockerPopover", bundle: nil)
        return storyboard.instantiateInitialViewController() as! ContentBlockerPopover
    }
    
    @IBAction func onUserTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension ContentBlockerPopover: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
