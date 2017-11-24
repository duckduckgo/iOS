//
//  PrivacyProtectionController.swift
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

protocol PrivacyProtectionDelegate: class {

    func omniBarTextTapped()

}

class PrivacyProtectionController: UIViewController {

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var omniBarContainer: UIView!

    weak var delegate: PrivacyProtectionDelegate?

    weak var embeddedController: UINavigationController!

    weak var omniBar: OmniBar!
    weak var omniDelegate: OmniBarDelegate!
    weak var siteRating: SiteRating?
    var omniBarText: String?
    var errorText: String?

    lazy var contentBlocker: ContentBlockerConfigurationStore = ContentBlockerConfigurationUserDefaults()

    override func viewDidLoad() {
        super.viewDidLoad()

        transitioningDelegate = self
        initOmniBar()

        if let errorText = errorText {
            showError(withText: errorText)
        } else {
            showInitialScreen()
        }

    }

    private func showError(withText errorText: String) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "Error") as? PrivacyProtectionErrorController else { return }
        controller.errorText = errorText
        embeddedController.pushViewController(controller, animated: true)
    }

    private func showInitialScreen() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "InitialScreen") as? PrivacyProtectionOverviewController else { return }
        embeddedController.pushViewController(controller, animated: true)
        updateViewControllers()
    }

    private func initOmniBar() {
        omniBar = OmniBar.loadFromXib()
        omniBar.frame = omniBarContainer.bounds
        omniBarContainer.addSubview(omniBar)
        omniBar.textField.text = omniBarText
        omniBar.updateSiteRating(siteRating)
        omniBar.startBrowsing()
        omniBar.omniDelegate = self
        omniBar.textField.addTarget(self, action: #selector(onTextFieldTapped), for: .touchDown)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? UINavigationController {
            embeddedController = controller
            updateViewControllers()
        }
    }

    @objc func onTextFieldTapped() {
        dismiss(animated: true) {
            self.delegate?.omniBarTextTapped()
        }
    }

    func updateSiteRating(_ siteRating: SiteRating?) {
        self.siteRating = siteRating
        omniBar.updateSiteRating(siteRating)
        omniBar.refreshText(forUrl: siteRating?.url)
        updateViewControllers()
    }

    func updateViewControllers() {
        guard let siteRating = siteRating else { return }
        for controller in embeddedController.viewControllers {
            guard let infoDisplaying = controller as? PrivacyProtectionInfoDisplaying else { continue }
            infoDisplaying.using(siteRating: siteRating, contentBlocker: contentBlocker)
        }
    }

}

extension PrivacyProtectionController: OmniBarDelegate {

    func onOmniQueryUpdated(_ query: String) {
        // no-op
    }

    func onOmniQuerySubmitted(_ query: String) {
        dismiss(animated: true) {
            self.omniDelegate.onOmniQuerySubmitted(query)
        }
    }

    func onDismissed() {
        // no-op
    }

    func onSiteRatingPressed() {
        dismiss(animated: true)
    }

    func onMenuPressed() {
        dismiss(animated: true) {
            self.omniDelegate.onMenuPressed()
        }
    }

    func onBookmarksPressed() {
        // shouldn't get called
    }

}

extension PrivacyProtectionController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInFromBelowOmniBarTransitioning()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpBehindOmniBarTransitioning()
    }

}

fileprivate struct AnimationConstants {
    static let inDuration = 0.3
    static let outDuration = 0.2
    static let tyOffset = CGFloat(20.0)
}

fileprivate class SlideUpBehindOmniBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromController = transitionContext.viewController(forKey: .from) as? PrivacyProtectionController else { return }

        fromController.view.backgroundColor = UIColor.clear

        toController.view.frame = transitionContext.finalFrame(for: toController)
        containerView.insertSubview(toController.view, at: 0)

        UIView.animate(withDuration: AnimationConstants.outDuration, animations: {
            fromController.contentContainer.transform.ty = -fromController.contentContainer.frame.size.height - fromController.omniBarContainer.frame.height - AnimationConstants.tyOffset
        }, completion: { (value: Bool) in
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.outDuration
    }

}

fileprivate class SlideInFromBelowOmniBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toController = transitionContext.viewController(forKey: .to) as? PrivacyProtectionController else { return }

        toController.view.frame = transitionContext.finalFrame(for: toController)
        containerView.addSubview(toController.view)

        let toColor = toController.view.backgroundColor
        toController.view.backgroundColor = UIColor.clear

        toController.contentContainer.transform.ty = -toController.contentContainer.frame.size.height - toController.omniBarContainer.frame.height - AnimationConstants.tyOffset

        UIView.animate(withDuration: AnimationConstants.inDuration, animations: {
            toController.contentContainer.transform.ty = 0
        }, completion: { (value: Bool) in
            toController.view.backgroundColor = toColor
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.inDuration
    }

}
