//
//  FireButton.swift
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

class FireButton: UIButton {

    private var animationView = AnimationView(name: "flame-light")
    private var currentlyLoadedStyle: ThemeManager.ImageSet = .light
    private var normalButtonImage: UIImage?
    
    public static func stopAllFireButtonAnimations() {
        NotificationCenter.default.post(name: .stopFireButtonAnimation, object: nil)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageAndAnimationView()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupImageAndAnimationView()
    }
    
    private func setupImageAndAnimationView() {
        setupAnimationView()
    }

    private func setupAnimationView() {
        animationView.clipsToBounds = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore
        
        addSubview(animationView)
        
        animationView.contentMode = .scaleAspectFit
        
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        animationView.isUserInteractionEnabled = false
        animationView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: isIPad ? -4 : -0.5).isActive = true
        animationView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: isIPad ? 4 : -0.5).isActive = true
        animationView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        animationView.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopFireButtonAnimation(_:)),
                                               name: .stopFireButtonAnimation,
                                               object: nil)
    }
    
    @objc private func stopFireButtonAnimation(_ notification: Notification) {
        stopAnimation()
    }

    public func playAnimation() {
        guard !animationView.isAnimationPlaying,
              let image = self.image(for: .normal) else { return }
        
        if normalButtonImage == nil {
            normalButtonImage = image
        }
        
        let blankImage = blankImage(for: image.size)
        setImage(blankImage, for: .normal)
        
        animationView.alpha = 1
        animationView.isHidden = false
        animationView.animationSpeed = 1.0
        
        animationView.play(fromFrame: 5, toFrame: 25, loopMode: .loop)
    }
    
    public func stopAnimation() {
        
        guard animationView.isAnimationPlaying,
              let image = normalButtonImage else { return }
        
        self.setImage(image, for: .normal)
        
        self.animationView.pause()
        
        UIView.animate(withDuration: 0.35, animations: {
            self.animationView.alpha = 0.0
        }, completion: { _ in
            self.animationView.stop()
        })
    }
    
    private func blankImage(for size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        let blankImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return blankImage
    }
}


extension FireBarButtonItem: Themable {

    func decorate(with theme: Theme) {
        button?.decorate(with: theme)
    }
}

extension FireButton: Themable {
    
    func decorate(with theme: Theme) {
        let newStyle = theme.currentImageSet
        
        if currentlyLoadedStyle != newStyle {
            let shouldResumePlaying = animationView.isAnimationPlaying
            
            switch newStyle {
            case .light:
                animationView.animation = Animation.named("flame-light")
            case .dark:
                animationView.animation = Animation.named("flame-dark")
            }
            
            if shouldResumePlaying {
                playAnimation()
            }
            
            currentlyLoadedStyle = newStyle
        }
    }
}

extension NSNotification.Name {
    
    static let stopFireButtonAnimation: NSNotification.Name = Notification.Name(rawValue: "com.duckduckgo.notification.stop-fire-button-animation")
    
}
