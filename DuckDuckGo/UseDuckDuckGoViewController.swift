//
//  UseDuckDuckGoViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class UseDuckDuckGoViewController: UIViewController {
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private static let minimumTopMargin: CGFloat = 0
    
    override func viewDidLayoutSubviews() {
        applyTopMargin()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
    
    private func applyTopMargin() {
        let availableHeight = view.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let excessHeight = availableHeight - contentHeight
        let marginForVerticalCentering = excessHeight / 2
        let minimumMargin = UseDuckDuckGoViewController.minimumTopMargin
        topMarginConstraint.constant = marginForVerticalCentering > minimumMargin ? marginForVerticalCentering : minimumMargin
    }
    
    @IBAction func onDonePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
