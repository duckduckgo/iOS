//
//  ContentBlockingConfiguration.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

struct ContentBlockingConfiguration: OnboardingPageConfiguration {
    
    var title: String {
        return UserText.onboardingContentBlockingTitle
    }
    
    var description: String {
        return UserText.onboardingContentBlockingDescription
    }
       
    var background: UIColor {
        return UIColor.onboardingContentBlockingBackground
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "OnboardingContentBlocking")
    }
}
