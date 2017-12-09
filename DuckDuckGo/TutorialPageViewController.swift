//
//  TutorialPageViewController.swift
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

class TutorialPageViewController: UIViewController {
    
    struct Constants {
        static let lineHeight: CGFloat = 1.375
    }
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var image: UIImageView!

    @IBOutlet var requiresLineHeightAdjustment: [UILabel]!

    @IBOutlet weak var searchDescription: UILabel!
    @IBOutlet weak var blockingDescription: UILabel!
    
    private lazy var interfaceMeasurement = InterfaceMeasurement(forScreen: UIScreen.main)

    private var _preferredBackgroundColor: UIColor!

    static func loadFromStoryboard(name: String) -> TutorialPageViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name) as! TutorialPageViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _preferredBackgroundColor = view.backgroundColor
        configureViews()
    }

    private func configureViews() {
        for label in requiresLineHeightAdjustment {
            label.adjustPlainTextLineHeight(Constants.lineHeight)
        }
    }

}

extension TutorialPageViewController: OnboardingPageViewController {

    var onboardingImage: UIImageView {
        return image
    }
    
    var preferredBackgroundColor: UIColor {
        get {
            return _preferredBackgroundColor
        }
    }

}
