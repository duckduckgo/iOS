//
//  OnboardingThemesViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 10/04/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class OnboardingThemesViewController: OnboardingContentViewController {
    
    @IBOutlet weak var lightThemeRadio: UIImageView!
    @IBOutlet weak var darkThemeRadio: UIImageView!
    
    var selectedTheme = ThemeName.dark
    
    let feedback = UISelectionFeedbackGenerator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedback.prepare()
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
    
    override func finished() {
        AppUserDefaults().currentThemeName = selectedTheme
    }
    
}
