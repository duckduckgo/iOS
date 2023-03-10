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
    
    var lottieButton: FireButton?
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        setupAnimation()
    }
    
    private func setupAnimation() {
        
//        let fireAnimationView = AnimationView(name: "flame")
//        fireAnimationView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        fireAnimationView.loopMode = .loop
//        fireAnimationView.backgroundBehavior = .pauseAndRestore
        
//        let lb = LottieButton()
//        lb.setImage(UIImage(named: "Fire"), for: .normal)
//        lb.animationName = "flame"
//
//        lottieButton = lb
        
        print(" -- image size: \(image?.size)")
        print(" -- custom view size: \(customView?.frame)")
        
//        let v = UIView()
//        v.backgroundColor = .magenta
//        v.frame = CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0)
//        customView = v
        
//        let v = AnimatedButton(animation: Animation.named("flame")!)
        
//        let v = FireButton(type: .system)
        let v = FireButton()
//        v.setImage(UIImage(named: "Fire"), for: .normal)
//        v.animationName = "flame"
        
        v.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        customView = v
        
        
        
    
        print(" -- custom view size: \(customView?.frame)")
        print(" -- inserted view size: \(v.frame)")
        
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        print(" -- pressed!")
        
        if let lottieButton = sender as? FireButton {
            lottieButton.playAnimation()
        }
        
    }
    
}

class FireButton: UIButton {

    private var animationView = AnimationView(name: "flame")
    
    convenience init() {
        self.init(type: .system)
        setImage(UIImage(named: "Fire"), for: .normal)
        add(animationView, into: self)
    }

    private func add(_ animationView: AnimationView, into view: UIView) {
        animationView.clipsToBounds = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .forceFinish
        
        view.addSubview(animationView)
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.isUserInteractionEnabled = false
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -0.5).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -0.5).isActive = true
        animationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
//        animationView.animationSpeed = 0.3
//        animationView.currentProgress = 1.0
//        animationView.alpha = 0.8
        
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
        
        let blankImage = self.blankImage(for: initialStateImage)
        self.setImage(blankImage, for: .normal)
        
        animationView.alpha = 1
        animationView.isHidden = false
                    
        self.animationView.play(completion: { _ in
            
            UIView.transition(with: self.imageView!,
                              duration: 2.0,
                              options: .transitionCrossDissolve,
                              animations: {
                
                self.setImage(finalStateImage, for: .normal)
                self.animationView.alpha = 0.0
                
            }, completion: { _ in
                self.animationView.stop()
            })
        })
        
    }

    open func playAnimation() {
        guard let image = self.image(for: .normal) else { return }
        self.playAnimation(withInitialStateImage: image, andFinalStateImage: image)
    }
}
