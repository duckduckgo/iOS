//
//  PrivacyRightConfiguration.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03//2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

struct PrivacyRightConfiguration: OnboardingPageConfiguration {
    
    var title: String {
        return UserText.onboardingPrivacyRightTitle
    }

    var description: String {
        return UserText.onboardingPrivacyRightDescription
    }
    
    var background: UIColor {
        return UIColor.onboardingPrivacyRightBackground
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "OnboardingPrivacyRight")
    }
}
