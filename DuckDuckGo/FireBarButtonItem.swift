//
//  FireBarButtonItem.swift
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
import Lottie

class FireBarButtonItem: UIBarButtonItem {
    
    var lottieButton: LottieButton?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setupAnimation()
    }
    
    private func setupAnimation() {
        
//        let fireAnimationView = AnimationView(name: "flame")
//        fireAnimationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        fireAnimationView.loopMode = .loop
//        fireAnimationView.backgroundBehavior = .pauseAndRestore
        
        let lb = LottieButton()
        lb.setImage(UIImage(named: "Fire"), for: .normal)
        lb.animationName = "flame"
        
        lottieButton = lb
        
        customView = lottieButton
    
        lottieButton?.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        lottieButton?.playAnimation()
    }
    
}

class LottieButton: UIButton {

    public private(set) var animationView: AnimationView?

    public var animationName: String? {
        didSet {
            self.animationView?.removeFromSuperview()
            self.animationView = AnimationView(name: animationName ?? "")

            if let animationView = self.animationView {
                self.add(animationView)
            }
        }
    }

    private func add(_ animationView: AnimationView) {
        self.addSubview(animationView)
        
        animationView.isHidden = true
    }

    private func blankImage(for image: UIImage?) -> UIImage? {
        UIGraphicsBeginImageContext(image?.size ?? .zero)
        let blankImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return blankImage
    }

    public func playAnimation(withInitialStateImage initialStateImage: UIImage,
                              andFinalStateImage finalStateImage: UIImage) {
        
        
        let snapshot = snapshotView(afterScreenUpdates: false)
        addSubview(snapshot!)
        
        
        let blankImage = self.blankImage(for: initialStateImage)
        self.setImage(blankImage, for: .normal)
        
        self.animationView?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.animationView?.center = center
        
        self.animationView?.alpha = 0
        self.animationView?.isHidden = false
        
        UIView.animate(withDuration: 2, delay: 0) {
            snapshot?.alpha = 0
            self.animationView?.alpha = 1
            
        }

//        self.animationView?.play(completion: { completed in
//            self.setImage(finalStateImage, for: .normal)
//            self.animationView?.isHidden = true
//            self.animationView?.pause()
//            self.animationView?.currentProgress = 0
//        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            snapshot?.removeFromSuperview()
            
            self.animationView?.play(completion: { completed in
                self.setImage(finalStateImage, for: .normal)
                self.animationView?.isHidden = true
                self.animationView?.pause()
                self.animationView?.currentProgress = 0
            })
        }
    }

    open func playAnimation() {
        guard let image = self.image(for: .normal) else { return }
        self.playAnimation(withInitialStateImage: image, andFinalStateImage: image)
    }
}
