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
    
    private struct Constants {
        static let animationDuration = 0.25
    }

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!

    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?

    var frame: CGRect!

    static func loadFromStoryboard(active: Bool) -> HomeViewController {
        let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frame = view.frame
        enterActiveMode()
        infoViewHeight.constant = 0
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chromeDelegate?.omniBar.becomeFirstResponder()  
    }
    
    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        let beginFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as! CGRect
        let endFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect
        let diff = beginFrame.origin.y - endFrame.origin.y

        if diff > 0 {
            bottomConstraint.constant = endFrame.size.height - (chromeDelegate?.toolbarHeight ?? 0) + 16
        } else {
            bottomConstraint.constant = 16
        }

        view.setNeedsUpdateConstraints()
        
        let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func enterActiveMode() {
        chromeDelegate?.setNavigationBarHidden(false)
        delegate?.homeDidActivateOmniBar(home: self)
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
