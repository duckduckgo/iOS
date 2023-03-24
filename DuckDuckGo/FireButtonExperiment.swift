//
//  FireButtonExperiment.swift
//  DuckDuckGo
//
//  Copyright © 2023 DuckDuckGo. All rights reserved.
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
import DuckUI
import Core

final class FireButtonExperiment {
    
    // MARK: - Experiment #1 - adding fire button animation
    
    private static var shouldPlayFireButtonAnimation: Bool {
        #warning("Define and check feature availability for variant")
        return true
        
        AppDependencyProvider.shared.variantManager.isSupported(feature: .fireButtonAnimation)
    }
    
    public static func restartFireButtonEducation() {
        DefaultDaxDialogsSettings().fireButtonEducationShownOrExpired = false
        DefaultDaxDialogsSettings().fireButtonPulseDateShown = nil
    }

    public static func playFireButtonAnimationOnTabSwitcher(fireButton: FireButton,
                                                            tabCount: Int) {
        guard shouldPlayFireButtonAnimation, tabCount > 1 else { return }
        
        fireButton.playAnimation()
    }
    
    public static func playFireButtonForOnboarding(fireButton: FireButton) {
        guard shouldPlayFireButtonAnimation else { return }
        
        fireButton.playAnimation()
    }
    
    
    //
    // MARK: - Experiment #2 - adding fire button color
    //
    
    private static var shouldUseFillColor: Bool {
        #warning("Define and check feature availability for variant")
        return false
        
         AppDependencyProvider.shared.variantManager.isSupported(feature: .fireButtonColor)
     }

     private static func fireButtonFillColor(for theme: Theme) -> UIColor {
         theme.currentImageSet == .light ? .redBase : .red40
     }

     public static func decorateFireButton(fireButton: UIBarButtonItem, for theme: Theme) {
         guard shouldUseFillColor else { return }

         fireButton.tintColor = fireButtonFillColor(for: theme)
     }

     public static func decorateFireButton(fireButton: UIButton, for theme: Theme) {
         guard shouldUseFillColor else { return }

         fireButton.tintColor = fireButtonFillColor(for: theme)
     }
}
