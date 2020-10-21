//
//  DaxOnboardingViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class DaxOnboardingViewController: UIViewController, Onboarding {
    
    struct Constants {
        
        static let animationDelay = 1.4
        static let animationDuration = 0.4
        
    }
    
    weak var delegate: OnboardingDelegate?
    weak var daxDialog: DaxDialogViewController?
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var daxDialogContainer: UIView!
    @IBOutlet weak var daxDialogContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var daxIcon: UIView!
    @IBOutlet weak var onboardingIcon: UIView!
    @IBOutlet weak var transitionalIcon: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isPad ? super.supportedInterfaceOrientations : [ .portrait ]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isPad ? super.preferredInterfaceOrientationForPresentation : .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        welcomeMessage.setAttributedTextString(UserText.launchscreenWelcomeMessage)
        daxDialog?.message = UserText.daxDialogOnboardingMessage
        daxDialog?.theme = LightTheme()
        daxDialog?.reset()
        daxDialogContainerHeight.constant = daxDialog?.calculateHeight() ?? 0
        button.displayDropShadow()
        daxIcon.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !view.isHidden else { return }
        
        daxDialogContainerHeight.constant = daxDialog?.calculateHeight() ?? 0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDelay) {
            self.transitionFromOnboarding()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        if let controller = segue.destination as? DaxDialogViewController {
            self.daxDialog = controller
        } else if let controller = segue.destination as? DaxOnboardingPadViewController {
            controller.delegate = self
        } else if let navController = segue.destination as? UINavigationController,
                  let controller = navController.viewControllers.first as? OnboardingViewController {
            controller.delegate = self
        }
        
    }

    func transitionFromOnboarding() {

        // using snapshots means the original views don't get messed up by their constraints when subsequent animations kick off
        let transitionIconSS: UIView = self.transitionalIcon.snapshotView(afterScreenUpdates: true) ?? self.transitionalIcon
        transitionIconSS.frame = self.transitionalIcon.frame
        view.addSubview(transitionIconSS)
        self.transitionalIcon.isHidden = true
        
        let onboardingIconSS: UIView = self.onboardingIcon.snapshotView(afterScreenUpdates: true) ?? self.onboardingIcon
        onboardingIconSS.frame = self.onboardingIcon.frame
        view.addSubview(onboardingIconSS)
        self.onboardingIcon.isHidden = true

        UIView.animate(withDuration: 0.3, animations: {
            
            // the dax dialog icon is not exactly centered with or the same size as this icon so we need to account for this in the animation
            onboardingIconSS.frame = CGRect(x: 0, y: 0, width: 76, height: 76)
            onboardingIconSS.center = CGPoint(x: self.daxIcon.center.x, y: self.daxIcon.center.y - 2)
            onboardingIconSS.alpha = 0.0

            transitionIconSS.frame = self.daxIcon.frame
            transitionIconSS.alpha = 1.0
            
            self.backgroundView.alpha = 0.0
        }, completion: { _ in
            self.daxIcon.isHidden = false
            onboardingIconSS.isHidden = true
            transitionIconSS.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                onboardingIconSS.removeFromSuperview()
                transitionIconSS.removeFromSuperview()
                self.transitionToDaxDialog()
            }
            
        })

    }

    func transitionToDaxDialog() {

        let snapshot: UIView = self.daxIcon.snapshotView(afterScreenUpdates: true) ?? self.daxIcon
        snapshot.frame = self.daxIcon.frame
        view.addSubview(snapshot)
        self.daxIcon.isHidden = true
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.welcomeMessage.alpha = 0.0

            if let frame = self.daxDialog?.icon.frame,
                let localFrame = self.daxDialog?.icon.superview!.convert(frame, to: self.view) {
                self.daxIcon.frame = localFrame
                snapshot.frame = localFrame
            }

        }, completion: { _ in
            
            // fade out while it's being shown again below, otherwise there's an abrupt change when the double dropshadow disappears
            UIView.animate(withDuration: 1.0, animations: {
                snapshot.alpha = 0.0
            }, completion: { _ in
                snapshot.removeFromSuperview()
            })
            
            self.showDaxDialog {
                self.daxDialog?.start()
            }
        })
        
    }
    
    @IBAction func onTapButton() {
        let segue = isPad ? "AddToHomeRow-iPad" : "AddToHomeRow"
        performSegue(withIdentifier: segue, sender: self)
    }
    
    func showDaxDialog(completion: @escaping () -> Void) {
        daxDialogContainer.alpha = 0.0
        daxDialogContainer.isHidden = false
        
        button.alpha = 0.0
        button.isHidden = false
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.daxDialogContainer.alpha = 1.0
            self.button.alpha = 1.0
        }, completion: { _ in
            completion()
        })
    }
    
}

extension DaxOnboardingViewController: OnboardingDelegate {
    func onboardingCompleted(controller: UIViewController) {
        self.view.isHidden = true
        controller.dismiss(animated: true)
        self.delegate?.onboardingCompleted(controller: self)
    }
}
