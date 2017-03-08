//
//  OnboardingPage.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 03/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

protocol OnboardingPage {
    
    var skipButtonHidden: Bool { get }
    
    var doneButtonText: String { get }
}
