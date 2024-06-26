//
//  OnboardingViewController.swift
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
import SwiftUI

class OnboardingViewController: UIViewController, Onboarding {
        
    private lazy var controllerNames: [String] = {
        return ["onboardingDefaultBrowser"]
    }()
    
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var subheader: UILabel!
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var subheaderContainer: UIView!
    @IBOutlet weak var contentWidth: NSLayoutConstraint!
    @IBOutlet weak var contentContainer: UIView!
    @IBOutlet weak var buttonsContainer: UIView!

    private let buttonsController = UIHostingController(rootView: OnboardingActions(viewModel: .init()))
    private var buttonsModel: OnboardingActions.Model {
        self.buttonsController.rootView.viewModel
    }

    var contentController: OnboardingContentViewController?
    
    private let variantManager = DefaultVariantManager()
    
    weak var delegate: OnboardingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpButtons()
        loadInitialContent()
        updateForSmallerScreens()
        setUpNavigationBar()
        decorate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    private func setUpNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }

    private func setUpButtons() {
        
        buttonsController.rootView.primaryAction = { [weak self] in
            self?.next(on: .continue)
        }

        buttonsController.rootView.secondaryAction = { [weak self] in
            self?.next(on: .skip)
        }

        buttonsController.view.backgroundColor = .clear

        addChild(buttonsController)
        buttonsContainer.addSubview(buttonsController.view)
        buttonsController.didMove(toParent: self)

        let buttonsView = buttonsController.view!
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonsView.leadingAnchor.constraint(equalTo: buttonsContainer.leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: buttonsContainer.trailingAnchor),
            buttonsView.topAnchor.constraint(equalTo: buttonsContainer.topAnchor),
            buttonsView.bottomAnchor.constraint(equalTo: buttonsContainer.bottomAnchor),
        ])
    }

    private func adjustHeight(label: UILabel, toMaxHeight maxHeight: CGFloat) -> CGFloat {
        guard var fontSize = label.attributedText?.font?.pointSize else { return label.bounds.height }
        
        var requiredHeight = label.sizeThatFits(CGSize(width: header.bounds.width, height: 1000)).height
        
        while requiredHeight > maxHeight, fontSize > 10 {
            fontSize -= 1.0
            label.attributedText = label.attributedText?.stringWithFontSize(fontSize)
            requiredHeight = label.sizeThatFits(CGSize(width: label.bounds.width, height: 1000)).height
        }
        
        return requiredHeight
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _ = adjustHeight(label: header, toMaxHeight: headerContainer.bounds.height - 10)
        _ = adjustHeight(label: subheader, toMaxHeight: subheaderContainer.bounds.height - 10)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? OnboardingContentViewController else {
            fatalError("destination controller is not \(OnboardingContentViewController.self)")
        }
        updateContent(controller)
    }

    private func updateContent(_ controller: OnboardingContentViewController) {
        controller.delegate = self
        buttonsModel.isContinueEnabled = controller.canContinue
        contentController = controller
        header.setAttributedTextString(controller.header)
        subheader.setAttributedTextString(controller.subtitle ?? "")
        UIAccessibility.post(notification: UIAccessibility.Notification.screenChanged, argument: header)
    }

    private func next(on button: ActionButton) {
        let navigationHandler = {
            if let name = self.controllerNames.first,
               let oldController = self.contentController,
               let newController = self.storyboard?.instantiateViewController(withIdentifier: name) as? OnboardingContentViewController {

                self.transition(from: oldController, to: newController)
            } else {
                self.done()
            }
        }

        switch button {
        case .continue:
            contentController?.onContinuePressed(navigationHandler: navigationHandler)
        case .skip:
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
            
            self.header.alpha = 0.0
            self.subheader.alpha = 0.0
            oldController.view.center.x -= frame.width * 1.0
            newController.view.center.x = frame.midX
            
        }, completion: { _ in
            
            oldController.view.removeFromSuperview()
            newController.didMove(toParent: self)
            self.contentContainer.addSubview(newController.view)
            self.updateContent(newController)
            self.animateInHeaders()
        })
        
        prepareFor(nextScreen: newController)
    }
    
    private func animateInHeaders() {
        UIView.animate(withDuration: 0.3) {
            self.header.alpha = 1.0
            self.subheader.alpha = 1.0
        }
    }
    
    private func prepareFor(nextScreen: OnboardingContentViewController) {
        controllerNames = [String](controllerNames.dropFirst())

        buttonsModel.primaryButtonTitle = nextScreen.continueButtonTitle
        buttonsModel.isContinueEnabled = nextScreen.canContinue

        buttonsModel.secondaryButtonTitle = nextScreen.skipButtonTitle
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
        buttonsModel.isContinueEnabled = enabled
    }
    
}

extension OnboardingViewController {
    private func decorate() {
        let theme = ThemeManager.shared.currentTheme

        view.backgroundColor = theme.onboardingBackgroundColor
        header.textColor = theme.onboardingHeaderColor
        subheader.textColor = theme.onboardingSubheaderColor
    }
}

private extension OnboardingViewController {
    enum ActionButton {
        case `continue`
        case skip
    }
}
