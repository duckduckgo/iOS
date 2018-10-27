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

    func reload()

}

class PrivacyProtectionController: UIViewController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return currentTheme.statusBarStyle
    }
    
    private var currentTheme = ThemeManager.shared.currentTheme

    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var omniBarContainer: UIView!
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var headerConstraint: NSLayoutConstraint!

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
        popoverPresentationController?.backgroundColor = view.backgroundColor

        initOmniBar()

        if !ContentBlockerLoader().hasData {
            showBlockerListError()
        } else if let errorText = errorText {
            showError(withText: errorText)
        } else if siteRating == nil {
            showError(withText: UserText.unknownErrorOccurred)
        } else {
            showInitialScreen()
        }

        applyTheme(currentTheme)
    }

    private func showError(withText errorText: String) {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "Error") as? PrivacyProtectionErrorController else { return }
        controller.errorText = errorText
        embeddedController.pushViewController(controller, animated: true)
    }

    private func showBlockerListError() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "Error") as? PrivacyProtectionErrorController else { return }
        controller.errorText = UserText.privacyProtectionReloadBlockerLists
        controller.delegate = self
        embeddedController.pushViewController(controller, animated: true)
    }

    private func showInitialScreen() {
        guard let controller = storyboard?.instantiateViewController(withIdentifier: "InitialScreen")
            as? PrivacyProtectionOverviewController else { return }
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
        guard let siteRating = siteRating else { return }
        omniBar.updateSiteRating(siteRating)
        omniBar.refreshText(forUrl: siteRating.url)
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

// Only use case just now is blocker lists not having downloaded
extension PrivacyProtectionController: PrivacyProtectionErrorDelegate {

    func canTryAgain(controller: PrivacyProtectionErrorController) -> Bool {
        return true
    }

    func tryAgain(controller: PrivacyProtectionErrorController) {
        ContentBlockerLoader().start { [weak self] newData in
            self?.handleBlockerListsLoaderResult(controller, newData)
        }
    }

    private func handleBlockerListsLoaderResult(_ controller: PrivacyProtectionErrorController, _ newData: Bool) {
        DispatchQueue.main.async {
            if newData {
                controller.dismiss(animated: true)
                self.delegate?.reload()
            } else {
                controller.resetTryAgain()
            }
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

    func onSettingsPressed() {
        // shouldn't get called
    }

}

extension PrivacyProtectionController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return SlideInFromBelowOmniBarTransitioning()
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideUpBehindOmniBarTransitioning()
    }

}

private struct AnimationConstants {
    static let inDuration = 0.3
    static let outDuration = 0.2
    static let tyOffset = CGFloat(20.0)
}

private class SlideUpBehindOmniBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        guard let toController = transitionContext.viewController(forKey: .to) else { return }
        guard let fromController = transitionContext.viewController(forKey: .from) as? PrivacyProtectionController else { return }

        fromController.view.backgroundColor = UIColor.clear

        toController.view.frame = transitionContext.finalFrame(for: toController)
        containerView.insertSubview(toController.view, at: 0)

        UIView.animate(withDuration: AnimationConstants.outDuration, animations: {
            fromController.contentContainer.transform.ty = -fromController.contentContainer.frame.size.height -
                fromController.omniBarContainer.frame.height -
                AnimationConstants.tyOffset
        }, completion: { (_: Bool) in
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.outDuration
    }

}

extension PrivacyProtectionController: UIPopoverPresentationControllerDelegate {

    func prepareForPopoverPresentation(_ popoverPresentationController: UIPopoverPresentationController) {
        view.bringSubviewToFront(contentContainer)
        headerConstraint.constant = -omniBarContainer.frame.size.height
    }

}

private class SlideInFromBelowOmniBarTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toController = transitionContext.viewController(forKey: .to) as? PrivacyProtectionController else { return }

        toController.view.frame = transitionContext.finalFrame(for: toController)
        containerView.addSubview(toController.view)

        let toColor = toController.view.backgroundColor
        toController.view.backgroundColor = UIColor.clear

        toController.contentContainer.transform.ty = -toController.contentContainer.frame.size.height
            - toController.omniBarContainer.frame.height
            - AnimationConstants.tyOffset

        UIView.animate(withDuration: AnimationConstants.inDuration, animations: {
            toController.contentContainer.transform.ty = 0
        }, completion: { (_: Bool) in
            toController.view.backgroundColor = toColor
            transitionContext.completeTransition(true)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return AnimationConstants.inDuration
    }

}

extension PrivacyProtectionController: Themable {
    
    func decorate(with theme: Theme) {
        currentTheme = theme
        setNeedsStatusBarAppearanceUpdate()
        
        statusBarBackground.backgroundColor = theme.barBackgroundColor
        omniBar?.applyTheme(theme)
    }
}
