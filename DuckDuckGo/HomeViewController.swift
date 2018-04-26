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
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    
    static func loadFromStoryboard(active: Bool) -> HomeViewController {
        let controller = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enterActiveMode()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        print(#function, "***", notification.userInfo)
        /*
Optional([AnyHashable("UIKeyboardCenterBeginUserInfoKey"): NSPoint: {207, 849}, AnyHashable("UIKeyboardIsLocalUserInfoKey"): 1, AnyHashable("UIKeyboardCenterEndUserInfoKey"): NSPoint: {207, 623}, AnyHashable("UIKeyboardBoundsUserInfoKey"): NSRect: {{0, 0}, {414, 226}}, AnyHashable("UIKeyboardFrameEndUserInfoKey"): NSRect: {{0, 510}, {414, 226}}, AnyHashable("UIKeyboardAnimationCurveUserInfoKey"): 7, AnyHashable("UIKeyboardFrameBeginUserInfoKey"): NSRect: {{0, 736}, {414, 226}}, AnyHashable("UIKeyboardAnimationDurationUserInfoKey"): 0.25])
        */
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
