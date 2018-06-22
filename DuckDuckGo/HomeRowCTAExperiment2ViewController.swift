//
//  HomeRowCTAExperiment2ViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 22/06/2018.
//  Copyright © 2018 DuckDuckGo. All rights reserved.
//

import UIKit

class HomeRowCTAExperiment2ViewController: UIViewController {
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var infoView: UIView!
    
    private var shown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.alpha = 0.0
        infoView.transform = CGAffineTransform(translationX: 0, y: 500)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeRowCTAExperiment2ViewController.onKeyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeRowCTAExperiment2ViewController.onKeyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !shown else { return }
        shown = true
        UIView.animate(withDuration: 1.0) {
            self.blurView.alpha = 1.0
            self.infoView.transform = CGAffineTransform.identity
        }
    }
    
    @objc func onKeyboardWillShow(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: max(duration, 0.3)) {
            self.view.alpha = 0.0
        }
    }
    
    @objc func onKeyboardWillHide(notification: NSNotification) {
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: max(duration, 0.3)) {
            self.view.alpha = 1.0
        }
    }

}
