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
    
    struct Constants {
        static let animationDuration = 1.4
        static let endAnimationDuration = 0.1
        static let initialFirePeekPortion: CGFloat = 0.15
    }
    
    static func animate(completion: @escaping () -> Swift.Void) {
        
        guard let window = UIApplication.shared.keyWindow else {
            completion()
            return
        }
        
        let animationContainer = UIView(frame: window.frame)
        animationContainer.autoresizingMask = .flexibleWidth

        let fireView = animatedFire(forContainer: animationContainer)
        animationContainer.addSubview(fireView)
        window.addSubview(animationContainer)
        
        let fireViewHeight = fireView.frame.size.height
        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            fireView.transform.ty = -fireViewHeight
        }) { _ in
            completion()
            UIView.animate(withDuration: Constants.endAnimationDuration, animations: {
            }) { _ in
                animationContainer.removeFromSuperview()
            }
        }
    }
    
    private static func animatedFire(forContainer container: UIView) -> UIView {
        let fireView = UIImageView(image: #imageLiteral(resourceName: "flames0001"))
        fireView.animationImages = animatedImages
        
        let containerHeight = container.frame.size.height
        let fireScale = fillWidthScale(view: fireView, container: container)
        let fireSize = CGSize(width: fireView.frame.width*fireScale, height: fireView.frame.height*fireScale)
        fireView.frame = CGRect(origin: fireView.frame.origin, size: fireSize)
        fireView.autoresizingMask = .flexibleWidth
        fireView.center.x = container.center.x
        fireView.transform.ty = containerHeight - fireView.frame.height * Constants.initialFirePeekPortion
        fireView.startAnimating()
        
        return fireView
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
    
    private static func fillWidthScale(view: UIView, container: UIView) -> CGFloat {
        let fillWidth = container.frame.width
        let width = view.frame.width
        if width < fillWidth {
            return fillWidth / width
        }
        return 1
    }
}
