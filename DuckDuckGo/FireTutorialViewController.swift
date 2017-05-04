//
//  FireTutorialViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 04/05/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

class FireTutorialViewController: UIViewController {
    
    @IBOutlet weak var descriptionText: UILabel!
    private var descriptionLineHeight: CGFloat = 1.375

    static func loadFromStoryboard() -> FireTutorialViewController {
        let storyboard = UIStoryboard.init(name: "FireTutorial", bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! FireTutorialViewController
        return controller
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        scaleDisplayOnSmallScreens()
    }

    private func configureViews() {
        descriptionText.adjustPlainTextLineHeight(descriptionLineHeight)
    }
    
    private func scaleDisplayOnSmallScreens() {
        if InterfaceMeasurement.isSmallScreenDevice {
            view.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }
    }
    
    @IBAction func onUserTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension FireTutorialViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {        return .none
    }
}
