//
//  Onboarding.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/02/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import Foundation

protocol OnboardingDelegate: NSObjectProtocol {
    
    func onboardingCompleted()
    
}

protocol Onboarding {
    
    var delegate: OnboardingDelegate? { get set }
    
}
