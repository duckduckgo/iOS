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
    
    @IBOutlet weak var ctaContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var ctaContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var ctaContainer: UIView!
    
    weak var delegate: HomeControllerDelegate?
    weak var chromeDelegate: BrowserChromeDelegate?
    weak var homeRowCTAController: UIViewController?
    
    private var viewHasAppeared = false
    private var defaultVerticalAlignConstant: CGFloat = 0

    static func loadFromStoryboard() -> HomeViewController {
        return UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.onKeyboardChangeFrame), name: .UIKeyboardWillChangeFrame, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let feature = HomeRowCTA()
        if let type = feature.ctaToShow() {
            applyHomeRowCTA(type: type)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewHasAppeared = true
    }

    @IBAction func hideKeyboard() {
        // without this the keyboard hides instantly and abruptly
        UIView.animate(withDuration: 0.5) {
            self.chromeDelegate?.omniBar.resignFirstResponder()
        }
    }
    
    @IBAction func showInstructions() {
        delegate?.showInstructions(self)
        dismissInstructions()
    }
    
    @IBAction func dismissInstructions() {
        HomeRowCTA().dismissed()
        hideCallToAction()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @objc func onKeyboardChangeFrame(notification: NSNotification) {
        guard let beginFrame = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? CGRect else { return }
        guard let endFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect else { return }
        guard let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double else { return }

        let diff = beginFrame.origin.y - endFrame.origin.y

        if diff > 0 {
            ctaContainerBottom.constant = endFrame.size.height - (chromeDelegate?.toolbarHeight ?? 0)
        } else {
            ctaContainerBottom.constant = 0
        }

        view.setNeedsUpdateConstraints()

        if viewHasAppeared {
            UIView.animate(withDuration: duration) { self.view.layoutIfNeeded() }
        }
    }

    
    private func hideCallToAction() {
        homeRowCTAController?.view.removeFromSuperview()
        homeRowCTAController?.removeFromParentViewController()
        homeRowCTAController = nil
    }
    
    private func applyHomeRowCTA(type: HomeRowCTA.CTAType) {
        guard homeRowCTAController == nil else { return }
        
        let childViewController = loadCTAViewController(forType: type)
        addChildViewController(childViewController)
        
        switch(type) {
            
        case .experiment1:
                updateUIForExperiment1(childViewController)
            
        case .experiment2:
                updateUIForExperiment2(childViewController)
            
        }
        
        childViewController.didMove(toParentViewController: self)
        self.homeRowCTAController = childViewController
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
    
    private func loadCTAViewController(forType type: HomeRowCTA.CTAType) -> UIViewController {
        let storyboard = UIStoryboard(name: "HomeRow", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: type.rawValue)
    }

    private func updateUIForExperiment1(_ childViewController: UIViewController) {
        ctaContainer.addSubview(childViewController.view)
        childViewController.view.frame = ctaContainer.bounds

        ctaContainerHeight.constant = childViewController.preferredContentSize.height
    }
 
    private func updateUIForExperiment2(_ childViewController: UIViewController) {
        view.addSubview(childViewController.view)
        childViewController.view.frame = view.bounds
    }
    
}
