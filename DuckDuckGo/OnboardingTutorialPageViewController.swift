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

    @IBOutlet weak var image: UIImageView!

    private(set) var preferredBackgroundColor: UIColor?

    static func loadFromStoryboard(name: String) -> OnboardingTutorialPageViewController {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: name) as? OnboardingTutorialPageViewController else {
            fatalError("Failed to instantiate view controller \(name) as OnboardingTutorialPageViewController")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredBackgroundColor = view.backgroundColor
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
