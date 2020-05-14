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
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return isPad ? super.supportedInterfaceOrientations : [ .portrait ]
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return isPad ? super.preferredInterfaceOrientationForPresentation : .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDelay) {
            self.transitionToDaxDialog()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        if segue.destination is DaxDialogViewController {
            self.daxDialog = segue.destination as? DaxDialogViewController
        }
        
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
                snapshot.frame = localFrame
            }

        }, completion: { _ in
            self.showDaxDialog {
                snapshot.removeFromSuperview()
                self.daxDialog?.onTapCta = self.onTapLetsGo
                self.daxDialog?.start()
            }
        })
        
    }
    
    func onTapLetsGo() {
        delegate?.onboardingCompleted(controller: self)
    }
    
    func showDaxDialog(completion: @escaping () -> Void) {
        let message = "The Internet can be kinda creepy.\n\nNot to worry! Searching and browsing\nprivately is easier than you think."
        let cta = "Let's Do It!"
        
        daxDialogContainer.alpha = 0.0
        daxDialogContainer.isHidden = false
        
        daxDialog?.message = message
        daxDialog?.cta = cta
        
        UIView.animate(withDuration: Constants.animationDuration, animations: {
            self.daxDialogContainer.alpha = 1.0
        }, completion: { _ in
            completion()
        })
    }
    
}
