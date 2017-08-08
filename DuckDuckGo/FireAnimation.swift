//
//  FireAnimation.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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

import APNGKit
import UIKit

struct FireAnimation {
    
    static func animate(withCompletion completion: @escaping () -> Swift.Void) {
        
        guard let window = UIApplication.shared.keyWindow else {
            completion()
            return
        }
        
        let animationContainer = UIView(frame: window.frame)
        let fireImage = APNGImage(named: "FireAnimated")!
        let fireView = APNGImageView(image: fireImage)
        fireView.autoStartAnimation = true
        
        let nativeHeight = fireView.frame.size.height
        fireView.center.x = animationContainer.center.x
        fireView.transform.ty = animationContainer.frame.size.height
        animationContainer.addSubview(fireView)
        window.addSubview(animationContainer)
        
        UIView.animate(withDuration: 1.5, animations: {
            fireView.transform.ty = -nativeHeight
        }) { _ in
            animationContainer.removeFromSuperview()
            completion()
        }
    }
}
