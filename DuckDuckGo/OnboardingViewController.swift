//
//  OnboardingSummaryViewController.swift
//  DuckDuckGo
//
//  Copyright © 2019 DuckDuckGo. All rights reserved.
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

class OnboardingViewController: UIViewController, Onboarding {
    
    var controllerNames = ["onboardingThemes", "onboardingSummary"]
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    var contentController: OnboardingContentViewController?
    
    weak var delegate: OnboardingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Pixel.fire(pixel: .onboardingShown)
        loadInitialContent()
        updateForSmallerScreens()
    }
    
    private func loadInitialContent() {
        guard let name = controllerNames.first,
            let controller = storyboard?.instantiateViewController(withIdentifier: name) as? OnboardingContentViewController else {
                fatalError("Unable to load initial content")
        }
        updateContent(controller)
        controller.view.frame = contentContainer.bounds
        contentContainer.addSubview(controller.view)
        addChild(controller)
        controller.didMove(toParent: self)
        
        prepareFor(nextScreen: controller)
    }
    
    private func updateForSmallerScreens() {
        contentWidth.constant = isSmall ? -52 : -72
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? OnboardingContentViewController else {
            fatalError("destination controller is not \(OnboardingContentViewController.self)")
        }
        updateContent(controller)
    }
    
    private func updateContent(_ controller: OnboardingContentViewController) {
        controller.delegate = self
        continueButton.isEnabled = controller.canContinue
        contentController = controller
        subheader.setAttributedTextString(controller.subtitle ?? "")
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: header)
    }
    
    @IBAction func next(sender: UIButton) {
        
        let navigationHandler = {
            if let name = self.controllerNames.first,
                let oldController = self.contentController,
                let newController = self.storyboard?.instantiateViewController(withIdentifier: name) as? OnboardingContentViewController {
                
                self.transition(from: oldController, to: newController)
            } else {
                self.done()
            }
        }

        if sender == continueButton {
            contentController?.onContinuePressed(navigationHandler: navigationHandler)
        } else {
            contentController?.onSkipPressed(navigationHandler: navigationHandler)
        }
    }
    
    private func transition(from oldController: OnboardingContentViewController, to newController: OnboardingContentViewController) {
        let frame = oldController.view.frame
        
        newController.view.frame = frame
        newController.view.center.x += (frame.width * 2.5)
        
        oldController.willMove(toParent: nil)
        addChild(newController)
        transition(from: oldController, to: newController, duration: 0.6, options: [], animations: {
            
            self.subheader.alpha = 0.0
            oldController.view.center.x -= frame.width * 1.0
            newController.view.center.x = frame.midX
            
        }, completion: { _ in
            
            oldController.view.removeFromSuperview()
            newController.didMove(toParent: self)
            self.contentContainer.addSubview(newController.view)
            self.updateContent(newController)
            self.animateInSubtitle()
            
        })
        
        prepareFor(nextScreen: newController)
    }
    
    private func animateInSubtitle() {
        UIView.animate(withDuration: 0.3) {
            self.subheader.alpha = 1.0
        }
    }
    
    private func prepareFor(nextScreen: OnboardingContentViewController) {
        controllerNames = [String](controllerNames.dropFirst())
        
        let continueButtonTitle = nextScreen.continueButtonTitle
        continueButton.setTitle(continueButtonTitle, for: .normal)
        continueButton.setTitle(continueButtonTitle, for: .disabled)
        continueButton.isEnabled = nextScreen.canContinue
        
        let skipButtonTitle = nextScreen.skipButtonTitle
        skipButton.setTitle(skipButtonTitle, for: .normal)
        skipButton.setTitle(skipButtonTitle, for: .disabled)
        skipButton.isHidden = controllerNames.isEmpty
    }
    
    func done() {
        delegate?.onboardingCompleted(controller: self)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [ .portrait ]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true 
    }
    
}

extension OnboardingViewController: OnboardingContentDelegate {
    
    func setContinueEnabled(_ enabled: Bool) {
        continueButton.isEnabled = enabled
    }
    
}
