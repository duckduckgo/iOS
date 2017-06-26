//
//  FireTutorialViewController.swift
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
        let measurements = InterfaceMeasurement(forScreen: UIScreen.main)
        if measurements.isSmallScreenDevice {
            view.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }
    }
    
    @IBAction func onUserTap(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension FireTutorialViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
