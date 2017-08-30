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

extension FireAnimation: NibLoading {}

class FireAnimation: UIView {

    @IBOutlet var image:UIImageView!

    struct Constants {
        static let animationDuration = 1.9
        static let endAnimationDuration = 0.3
    }
    
    static func animate(completion: @escaping () -> Swift.Void) {
        
        guard let window = UIApplication.shared.keyWindow else {
            completion()
            return
        }

        let anim = FireAnimation.load(nibName: "FireAnimation")
        anim.image.animationImages = animatedImages
        anim.image.startAnimating()

        anim.frame = window.frame
        anim.transform.ty = anim.frame.size.height
        window.addSubview(anim)

        UIView.animate(withDuration: Constants.animationDuration, delay: 0, options: .curveEaseOut, animations: {
            anim.transform.ty = -200
        }) { _ in
            completion()
        }

        UIView.animate(withDuration: Constants.endAnimationDuration, delay: Constants.animationDuration, options: .curveEaseOut, animations: {
            anim.alpha = 0
        }) { _ in
            anim.removeFromSuperview()
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
