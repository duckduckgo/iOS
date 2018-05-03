//
//  HomeViewController.swift
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
import Core

class HomeViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var infoView: UIView!

    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?

    var frame: CGRect!

    static func loadFromStoryboard() -> HomeViewController {
        return UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frame = view.frame
        
        updateInfoView()
        activateOmniBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let feature = HomeRowOnboarding()
        if !feature.showNow() {
            hideCallToAction()
        }    
    }
    
    @IBAction func hideKeyboard() {
        chromeDelegate?.omniBar.resignFirstResponder()
    }
    
    @IBAction func showInstructions() {
        delegate?.showInstructions(self)
        dismissInstructions()
    }
    
    @IBAction func dismissInstructions() {
        HomeRowOnboarding().dismissed()
        hideCallToAction()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func showSettings() {
        delegate?.showSettings(self)
    }

    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        guard let beginFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let endFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }

        let diff = beginFrame.origin.y - endFrame.origin.y

        if diff > 0 {
            bottomConstraint.constant = endFrame.size.height - (chromeDelegate?.toolbarHeight ?? 0) + 16
        } else {
            bottomConstraint.constant = 16
        }

        view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateInfoView() {
        infoView.layer.cornerRadius = 5
        infoView.layer.borderColor = UIColor.greyishBrownTwo.cgColor
        infoView.layer.borderWidth = 1
        infoView.layer.masksToBounds = true
    }
    
    private func activateOmniBar() {
        chromeDelegate?.setNavigationBarHidden(false)
        delegate?.homeDidActivateOmniBar(home: self)
    }

    private func hideCallToAction() {
        infoView.isHidden = true
        infoViewHeight.constant = 0
    }
    
    func load(url: URL) {
        delegate?.home(self, didRequestUrl: url)
    }
    
    func dismiss() {
        delegate = nil
        chromeDelegate = nil
        removeFromParentViewController()
        view.removeFromSuperview()
    }

}
