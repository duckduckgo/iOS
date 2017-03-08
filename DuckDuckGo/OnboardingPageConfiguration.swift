//
//  OnboardingPageConfiguration.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

protocol OnboardingPageConfiguration {
    
    var title: String { get }
    
    var description: String { get }
    
    var image: UIImage { get }
    
    var background: UIColor { get }
}
