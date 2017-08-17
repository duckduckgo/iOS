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

import UIKit

struct FireAnimation {
    
    static func animate(completion: @escaping () -> Swift.Void) {
        
        guard let window = UIApplication.shared.keyWindow else {
            completion()
            return
        }
        
        let animationContainer = UIView(frame: window.frame)
        let fireView = UIImageView(image: #imageLiteral(resourceName: "flames0001"))
        fireView.animationImages = animatedImages

        let containerHeight = animationContainer.frame.size.height
        let fireViewHeight = fireView.frame.size.height
        fireView.center.x = animationContainer.center.x
        fireView.transform.ty = containerHeight - fireViewHeight * 0.15
        animationContainer.addSubview(fireView)
        window.addSubview(animationContainer)
        
        fireView.startAnimating()
        UIView.animate(withDuration: 1.4, delay: 0, options: .curveEaseOut, animations: {
            fireView.transform.ty = -fireViewHeight
        }) { _ in
            completion()
            UIView.animate(withDuration: 0.1, animations: {
            }) { _ in
                animationContainer.removeFromSuperview()
            }
        }
    }
    
    private static var animatedImages: [UIImage] {
        var images = [UIImage]()
        for i in 1...20 {
            let filename = String(format: "flames00%02d", i)
            let image = #imageLiteral(resourceName: filename)
            images.append(image)
        }
        return images
    }
}
