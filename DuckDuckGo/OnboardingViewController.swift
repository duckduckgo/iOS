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

    var controllerNames = [ "Themes", "Summary" ]
    
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var headerVerticalSpacing: NSLayoutConstraint!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!

    var contentController: OnboardingContentViewController?
    
    weak var delegate: OnboardingDelegate?

    var variant: Variant {
        guard let variant = DefaultVariantManager().currentVariant else {
            fatalError("No variant")
        }

        return variant
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Pixel.fire(pixel: .onboardingShown)
        updateForSmallScreens()
        updateControllerNames()
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
        subheader.text = controller.subtitle
    }
    
    private func updateForSmallScreens() {
        subheader.isHidden = isSmall
        headerVerticalSpacing.constant = isSmall ? 12 : 50
    }
    
    @IBAction func next() {
        
        if let nextController = controllerNames.first,
            let oldController = contentController,
            let newController = storyboard?.instantiateViewController(withIdentifier: nextController) as? OnboardingContentViewController {
            
            let frame = oldController.view.frame
            
            newController.view.frame = frame
            newController.view.center.x += (frame.width * 2.5)
            
            oldController.willMove(toParent: nil)
            addChild(newController)
            transition(from: oldController, to: newController, duration: 0.6, options: [], animations: {
                
                self.subheader.alpha = 0.0
                oldController.view.center.x -= (frame.width * 1.0)
                newController.view.center.x = frame.midX
                
            }, completion: { _ in
                
                oldController.view.removeFromSuperview()
                newController.didMove(toParent: self)
                self.contentContainer.addSubview(newController.view)
                self.updateContent(newController)
                self.animateInSubtitle()
                
            })
            
            updateControllerNames()
        } else {
            done()
        }
        
    }
    
    private func animateInSubtitle() {
        UIView.animate(withDuration: 0.3) {
            self.subheader.alpha = 1.0
        }
    }
    
    private func updateControllerNames() {
        controllerNames = [String](controllerNames.dropFirst())
        controllerNames += [ "Themes", "Summary" ]
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
