//
//  TrackingConfiguration.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03//2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

struct TrackingConfiguration: OnboardingPageConfiguration {
    
    var title: String {
        return UserText.onboardingTrackingTitle
    }
    
    var description: String {
        return UserText.onboardingTrackingDescription
    }
        
    var background: UIColor {
        return UIColor.onboardingTrackingBackground
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "OnboardingNoTracking")
    }
}
