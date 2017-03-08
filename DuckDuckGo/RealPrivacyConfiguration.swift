//
//  RealPrivacyConfiguration.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03//2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

struct RealPrivacyConfiguration: OnboardingPageConfiguration {
    
    var title: String {
        return UserText.onboardingRealPrivacyTitle
    }

    var description: String {
        return UserText.onboardingRealPrivacyDescription
    }
        
    var background: UIColor {
        return UIColor.onboardingRealPrivacyBackground
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "OnboardingRealPrivacy")
    }
}
