//
//  DaxOnboardingViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 12/05/2020.
//  Copyright © 2020 DuckDuckGo. All rights reserved.
//

import UIKit

class DaxOnboardingViewController: UIViewController, Onboarding {
    
    struct Constants {
        
        static let animationDelay = 1.4
        static let animationDuration = 0.4
        
    }
    
    weak var delegate: OnboardingDelegate?
    weak var daxDialog: DaxDialogViewController?
    
    @IBOutlet weak var welcomeMessage: UIView!
    @IBOutlet weak var daxDialogContainer: UIView!
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
        button.displayDropShadow()
        daxIcon.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDelay) {
            self.transitionFromOnboarding()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        if segue.destination is DaxDialogViewController {
            self.daxDialog = segue.destination as? DaxDialogViewController
        }
        
    }

    func transitionFromOnboarding() {

        let snapshot = self.onboardingIcon.snapshotView(afterScreenUpdates: false)!
        snapshot.frame = self.onboardingIcon.frame
        view.addSubview(snapshot)
        self.onboardingIcon.isHidden = true

        self.daxIcon.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            snapshot.frame = CGRect(x: 0, y: 0, width: 76, height: 76)
            snapshot.center = CGPoint(x: self.daxIcon.center.x, y: self.daxIcon.center.y - 2)
            self.backgroundView.alpha = 0.0
        }, completion: { _ in
            self.daxIcon.isHidden = false
            
            UIView.animate(withDuration: 0.3, animations: {
                snapshot.alpha = 0.0
                self.daxIcon.alpha = 1.0
            }, completion: { _ in

                self.onboardingIcon.isHidden = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    snapshot.removeFromSuperview()
                    self.transitionToDaxDialog()
                }

            })
            
        })

    }

    func transitionToDaxDialog() {

        let snapshot = self.daxIcon.snapshotView(afterScreenUpdates: false)!
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
            self.showDaxDialog {
                snapshot.removeFromSuperview()
                self.daxDialog?.start()
            }
        })
        
    }
    
    @IBAction func onTapButton() {
        delegate?.onboardingCompleted(controller: self)
    }
    
    func showDaxDialog(completion: @escaping () -> Void) {
        let message = "The Internet can be kinda creepy.\n\nNot to worry! Searching and browsing privately is easier than you think."
        
        daxDialogContainer.alpha = 0.0
        daxDialogContainer.isHidden = false
        
        button.alpha = 0.0
        button.isHidden = false
        
        daxDialog?.message = message
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.daxDialogContainer.alpha = 1.0
            self.button.alpha = 1.0
        }, completion: { _ in
            completion()
        })
    }
    
}
