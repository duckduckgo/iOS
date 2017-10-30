//
//  PrivacyProtectionDashboard.swift
//  DuckDuckGo
//
//  Created by Christopher Brind on 30/10/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class PrivacyProtectionDashboardController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var omniBarContainer: UIView!

    static func loadFromStoryboard() -> PrivacyProtectionDashboardController {
        let storyboard = UIStoryboard(name: "PrivacyProtection", bundle: nil)
        return storyboard.instantiateInitialViewController() as! PrivacyProtectionDashboardController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self

        initTableView()
        initOmniBar()
    }

    private func initTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    private func initOmniBar() {
        let omniBar = OmniBar.loadFromXib()
        omniBar.frame = omniBarContainer.bounds
        omniBarContainer.addSubview(omniBar)
    }

}

extension PrivacyProtectionDashboardController: UITableViewDelegate {

}

extension PrivacyProtectionDashboardController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "PrivacyGrade")!
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 203
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
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        containerView.blur(style: .dark)

        guard let toController = transitionContext.viewController(forKey: .to) as? PrivacyProtectionDashboardController else { return }

        containerView.addSubview(toController.view)

        let toColor = toController.view.backgroundColor
        toController.view.backgroundColor = UIColor.clear

        toController.tableView.transform.ty = -toController.tableView.frame.size.height
        UIView.animate(withDuration: Constants.duration, animations: {
            toController.tableView.transform.ty = 0
        }, completion: { (value: Bool) in
            toController.view.backgroundColor = toColor
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Constants.duration
    }

}
