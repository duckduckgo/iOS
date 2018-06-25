//
//  HomeRowCTAExperiment2ViewController.swift
//  DuckDuckGo
//
//  Copyright © 2018 DuckDuckGo. All rights reserved.
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

class HomeRowCTAExperiment2ViewController: UIViewController {
    
    struct Constants {
        
        static let appearanceAnimationDuration = 1.0
        
    }
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var showMeButton: UIButton!
    
    private var shown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureForFirstAppearance()
        addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateOnFirstAppearance()
    }
    
    @IBAction func noThanks() {
        dismiss()
    }
    
    @objc func onKeyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: notification.keyboardAnimationDuration()) {
            self.view.alpha = 0.0
        }
    }
    
    @objc func onKeyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: notification.keyboardAnimationDuration()) {
            self.view.alpha = 1.0
        }
    }
    
    private func configureViews() {
        showMeButton.layer.cornerRadius = 4
        showMeButton.layer.masksToBounds = true
    }
    
    private func configureForFirstAppearance() {
        blurView.alpha = 0.0
        infoView.transform = CGAffineTransform(translationX: 0, y: infoView.frame.size.height + CGFloat(#imageLiteral(resourceName: "HomeRowAppIcon").cgImage?.height ?? 0))
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeRowCTAExperiment2ViewController.onKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeRowCTAExperiment2ViewController.onKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    private func animateOnFirstAppearance() {
        guard !shown else { return }
        shown = true
        UIView.animate(withDuration: Constants.appearanceAnimationDuration) {
            self.blurView.alpha = 1.0
            self.infoView.transform = CGAffineTransform.identity
        }
    }
    
    private func dismiss() {
        HomeRowCTA().dismissed()
        UIView.animate(withDuration: Constants.appearanceAnimationDuration) {
            self.configureForFirstAppearance()
        }
    }
    
}

fileprivate extension NSNotification {
    
    func keyboardAnimationDuration() -> Double {
        let defaultDuration = 0.3
        let duration = userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? defaultDuration
        // the animation duration in userInfo could be 0, so ensure we always have some animation
        return min(duration, defaultDuration)
    }
    
}
