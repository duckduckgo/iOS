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
    
    private(set) var button: FireButton?
    
    override var tintColor: UIColor? {
        didSet {
            button?.tintColor = tintColor
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupAnimation()
    }
    
    private func setupAnimation() {
        button = FireButton(type: .system)
        
        button?.setImage(image, for: .normal)
        button?.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        customView = button
    }
    
    @IBAction func onButtonPressed(_ sender: Any) {
        guard let target = target, let action = action else { return }
        
        UIApplication.shared.sendAction(action, to: target, from: nil, for: nil)
    }
    
    public func playAnimation(delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.button?.playAnimation()
        }
    }
    
    public func stopAnimation() {
        button?.stopAnimation()
    }
}

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
//        setImage(UIImage(named: "Fire"), for: .normal)
        add(animationView, into: self)
    }

    private func add(_ animationView: AnimationView, into view: UIView) {
        animationView.clipsToBounds = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.backgroundBehavior = .pauseAndRestore
        
        view.addSubview(animationView)
        
        animationView.contentMode = .scaleAspectFit
        
        let isIPad = UIDevice.current.userInterfaceIdiom == .pad
        
        animationView.isUserInteractionEnabled = false
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: isIPad ? -4 : -0.5).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: isIPad ? 4 : -0.5).isActive = true
        animationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        animationView.isHidden = true
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(stopFireButtonAnimation(_:)),
                                               name: .stopFireButtonAnimation,
                                               object: nil)
    }
    
    @objc private func stopFireButtonAnimation(_ notification: Notification) {
        stopAnimation()
    }
    
    public func playAnimation(delay: TimeInterval = 0) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            self.playAnimation()
        }
    }
    
    public func playAnimation() {
        print(" -- playAnimation()")
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
        
        // test of looped animation
//        self.animationView.play(fromFrame: 0, toFrame: 5, completion: { completed in
//            guard completed else { return }
            
            self.animationView.play(fromFrame: 5, toFrame: 25, loopMode: .loop)
            
//            self.animationView.play(fromFrame: 5, toFrame: 25, loopMode: .playOnce, completion: { completed in
//                guard completed else { return }
//
//                self.setImage(image, for: .normal)
//
//                UIView.animate(withDuration: 0.35, animations: {
//                    self.animationView.alpha = 0.0
//                }, completion: { _ in
//                    self.animationView.stop()
//                })
//            })
            
//        })
        
        // old style animation
//        self.animationView.play(completion: { _ in
//            self.setImage(image, for: .normal)
//
//            UIView.animate(withDuration: 0.35, animations: {
//                self.animationView.alpha = 0.0
//            }, completion: { _ in
//                self.animationView.stop()
//            })
//        })
    }
    
    public func stopAnimation() {
        print(" -- stopAnimation()")
        
        guard animationView.isAnimationPlaying,
              let image = normalButtonImage else { return }
        
        //        self.animationView.play(fromFrame: 25, toFrame: 30, completion: { _ in
        self.setImage(image, for: .normal)
        self.animationView.pause()
        
        UIView.animate(withDuration: 0.35, animations: {
            self.animationView.alpha = 0.0
        }, completion: { _ in
            self.animationView.stop()
        })
//        })
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
