//
//  OnboardingThemesViewController.swift
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

import UIKit
import Core

class OnboardingThemesViewController: OnboardingContentViewController {
    
    @IBOutlet weak var lightThemeRadio: UIImageView!
    @IBOutlet weak var darkThemeRadio: UIImageView!
    
    var timedPixel: TimedPixel?
    
    var selectedTheme = ThemeName.dark
    var exitPixel = PixelName.onboardingThemesSkipped
    
    let feedback = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback.prepare()
        timedPixel = TimedPixel(.onboardingThemesFinished)
        canContinue = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timedPixel?.fire()
        Pixel.fire(pixel: exitPixel)
    }
    
    @IBAction func selectLightTheme() {
        lightThemeRadio.image = #imageLiteral(resourceName: "OnboardingRadioSelected")
        darkThemeRadio.image = #imageLiteral(resourceName: "OnboardingRadioUnselected")
        delegate?.setContinueEnabled(true)
        lightThemeRadio.accessibilityTraits.formUnion(.selected)
        darkThemeRadio.accessibilityTraits.remove(.selected)
        feedback.selectionChanged()
        selectedTheme = .light
    }
    
    @IBAction func selectDarkTheme() {
        darkThemeRadio.image = #imageLiteral(resourceName: "OnboardingRadioSelected")
        lightThemeRadio.image = #imageLiteral(resourceName: "OnboardingRadioUnselected")
        delegate?.setContinueEnabled(true)
        darkThemeRadio.accessibilityTraits.formUnion(.selected)
        lightThemeRadio.accessibilityTraits.remove(.selected)
        feedback.selectionChanged()
        selectedTheme = .dark
    }
    
    override func onContinuePressed() {
        exitPixel = selectedTheme == .dark ? .onboardingThemesDarkThemeSelected : .onboardingThemesLightThemeSelected
        ThemeManager.shared.enableTheme(with: selectedTheme)
    }
    
}
