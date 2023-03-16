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
    
    private static var shouldPlayFireButtonAnimation: Bool {
        true
//        AppDependencyProvider.shared.variantManager.isSupported(feature: .fireButtonWithColorFill)
    }

    public static func playFireButtonAnimationOnTabSwitcher(fireButton: FireBarButtonItem,
                                                            tabCount: Int,
                                                            delay: TimeInterval = 0) {
        guard shouldPlayFireButtonAnimation, tabCount > 1 else { return }
        
        fireButton.playAnimation(delay: delay)
    }
    
    public static func playFireButtonForOnboarding(fireButton: FireButton,
                                                   delay: TimeInterval = 0) {
        guard shouldPlayFireButtonAnimation else { return }
        
        fireButton.playAnimation(delay: delay)
    }
}
