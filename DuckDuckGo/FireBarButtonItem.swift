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
    
    private var fireButton: FireButton?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupAnimation()
    }
    
    private func setupAnimation() {
        fireButton = FireButton()
        fireButton?.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        customView = fireButton
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        guard let target = target, let action = action else { return }
        
        UIApplication.shared.sendAction(action, to: target, from: nil, for: nil)
    }
    
    public func playAnimation() {
        fireButton?.playAnimation()
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
        
        animationView.isHidden = true
    }
    
    public func playAnimation() {
        guard !animationView.isAnimationPlaying,
              let image = self.image(for: .normal) else { return }
        
        let blankImage = blankImage(for: image.size)
        setImage(blankImage, for: .normal)
        
        animationView.alpha = 1
        animationView.isHidden = false
        
        self.animationView.play(completion: { _ in
            self.setImage(image, for: .normal)
            
            UIView.animate(withDuration: 0.35, animations: {
                self.animationView.alpha = 0.0
            }, completion: { _ in
                self.animationView.stop()
            })
        })
    }
    
    private func blankImage(for size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let blankImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return blankImage
    }
}
