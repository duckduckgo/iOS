//
//  OnboardingTutorialPageViewController.swift
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

class OnboardingTutorialPageViewController: UIViewController {
    
    struct Constants {
        static let lineHeight: CGFloat = 1.375
    }
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet var requiresLineHeightAdjustment: [UILabel]!

    private(set) var preferredBackgroundColor: UIColor?

    static func loadFromStoryboard(name: String) -> OnboardingTutorialPageViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: name) as! OnboardingTutorialPageViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preferredBackgroundColor = view.backgroundColor
        configureViews()
    }

    private func configureViews() {
        guard requiresLineHeightAdjustment != nil else { return }
        for label in requiresLineHeightAdjustment {
            label.adjustPlainTextLineHeight(Constants.lineHeight)
        }
    }

    var onboardingImage: UIImageView {
        return image
    }

    func scaleImage(_ scale: CGFloat) {
        onboardingImage.transform = CGAffineTransform(scaleX: scale, y: scale)
    }

    func resetImage() {
        onboardingImage.transform = CGAffineTransform.identity
    }

}
