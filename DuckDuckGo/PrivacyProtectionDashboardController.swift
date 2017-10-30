//
//  PrivacyProtectionDashboard.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 30/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class PrivacyProtectionDashboardController: UIViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var omniBarContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self

        initOmniBar()
    }

    private func initOmniBar() {
        let omniBar = OmniBar.loadFromXib()
        omniBar.frame = omniBarContainer.bounds
        omniBarContainer.addSubview(omniBar)
    }

}


extension PrivacyProtectionDashboardController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInFromBelowOmniBarTransitioning()
    }

}

class SlideInFromBelowOmniBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    struct Constants {
        static let duration = 0.3
        static let tyOffset = CGFloat(20.0)
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.blur(style: .dark)

        guard let toController = transitionContext.viewController(forKey: .to) as? PrivacyProtectionDashboardController else { return }

        containerView.addSubview(toController.view)

        let toColor = toController.view.backgroundColor
        toController.view.backgroundColor = UIColor.clear

        toController.contentContainer.transform.ty = -toController.contentContainer.frame.size.height - toController.omniBarContainer.frame.height - Constants.tyOffset

        UIView.animate(withDuration: Constants.duration, animations: {
            toController.contentContainer.transform.ty = 0
        }, completion: { (value: Bool) in
            toController.view.backgroundColor = toColor
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }

}
