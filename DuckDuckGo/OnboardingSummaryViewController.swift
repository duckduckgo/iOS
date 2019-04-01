//
//  OnboardingSummaryViewController.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class OnboardingSummaryViewController: UIViewController, Onboarding {

    @IBOutlet weak var secondaryButtonContainer: UIView!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var subheader: UIView!
    @IBOutlet weak var bulletsWidth: NSLayoutConstraint!
    @IBOutlet weak var bulletsStack: UIStackView!
    @IBOutlet weak var headerPadding: NSLayoutConstraint!

    weak var delegate: OnboardingDelegate?

    var onboardingSettingsPixelFired = false
    var onboardingExplorePrivacyPixelFire = false
    
    var variant: Variant {
        guard let variant = DefaultVariantManager().currentVariant else {
            fatalError("No variant")
        }

        return variant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Pixel.fire(pixel: .onboardingShown)
        updateSecondaryButton()
        updateForSmallScreens()
    }
    
    private func updateForSmallScreens() {
        let isSmall = view.frame.height <= 568
        subheader.isHidden = isSmall
        bulletsWidth.constant = isSmall ? -52 : -72
        bulletsStack.spacing = isSmall ? 8 : 12
        headerPadding.constant = isSmall ? 16 : 30
    }
    
    private func updateSecondaryButton() {
        if variant.features.contains(.onboardingCustomizeSettings) {
            secondaryButton.setTitle("Customize Your Settings", for: .normal)
        } else if variant.features.contains(.onboardingExplorePrivacy) {
            secondaryButton.setTitle("Explore Privacy Features", for: .normal)
        } else {
            secondaryButtonContainer.isHidden = true
        }
    }
    
    @IBAction func secondaryButtonAction() {
        if variant.features.contains(.onboardingCustomizeSettings) {
            customizeSettings()
        } else if variant.features.contains(.onboardingExplorePrivacy) {
            explorePrivacy()
        } else {
            fatalError("Unexpected variant \(variant.name)")
        }
    }
    
    private func customizeSettings() {
        guard let delegate = delegate else { return }
        if !onboardingSettingsPixelFired {
            Pixel.fire(pixel: .onboardingCustomizeSettings)
            onboardingSettingsPixelFired = true
        }
        delegate.customizeSettings(controller: self)
    }
    
    private func explorePrivacy() {
        guard let delegate = delegate else { return }
        if !onboardingExplorePrivacyPixelFire {
            Pixel.fire(pixel: .onboardingExplorePrivacy)
            onboardingExplorePrivacyPixelFire = true
        }
        delegate.explorePrivacyFeatures(controller: self)
    }
    
    @IBAction func done() {
        delegate?.onboardingCompleted(controller: self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [ .portrait ]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true 
    }
    
}
