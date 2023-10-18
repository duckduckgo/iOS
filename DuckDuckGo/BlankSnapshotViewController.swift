//
//  BlankSnapshotViewController.swift
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

protocol BlankSnapshotViewRecoveringDelegate: AnyObject {
    
    func recoverFromPresenting(controller: BlankSnapshotViewController)
}

// Still some logic here that should be de-duplicated from MainViewController
class BlankSnapshotViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    let menuButton = MenuButton()

    let tabSwitcherButton = TabSwitcherButton()
    let appSettings: AppSettings

    var viewCoordinator: MainViewCoordinator!

    weak var delegate: BlankSnapshotViewRecoveringDelegate?

    init(appSettings: AppSettings) {
        self.appSettings = appSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewCoordinator = MainViewFactory.createViewHierarchy(view)
        if appSettings.currentAddressBarPosition.isBottom {
            viewCoordinator.moveAddressBarToPosition(.bottom)
            viewCoordinator.hideToolbarSeparator()
        }

        configureOmniBar()
        configureToolbarButtons()

        if AppWidthObserver.shared.isLargeWidth {
            viewCoordinator.toolbar.isHidden = true
            viewCoordinator.constraints.navigationBarContainerTop.constant = 40
            configureTabBar()
        } else {
            viewCoordinator.toolbarTabSwitcherButton.customView = tabSwitcherButton
            tabSwitcherButton.delegate = self
            
            viewCoordinator.lastToolbarButton.customView = menuButton
            menuButton.setState(.menuImage, animated: false)
            viewCoordinator.lastToolbarButton.customView = menuButton
        }

        applyTheme(ThemeManager.shared.currentTheme)
    }

    // Need to do this at this phase to support split screen on iPad
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewCoordinator.toolbar.isHidden = AppWidthObserver.shared.isLargeWidth
    }

    private func configureToolbarButtons() {
        viewCoordinator.toolbarFireButton.action = #selector(buttonPressed(sender:))
        viewCoordinator.toolbarFireButton.action = #selector(buttonPressed(sender:))
        viewCoordinator.lastToolbarButton.action = #selector(buttonPressed(sender:))
    }

    private func configureTabBar() {
        let storyboard = UIStoryboard(name: "TabSwitcher", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "TabsBar") as? TabsBarViewController else {
            fatalError("Failed to instantiate tabs bar controller")
        }
        controller.view.frame = CGRect(x: 0, y: 24, width: view.frame.width, height: 40)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controller.view)
        
        controller.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        controller.view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        controller.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 24.0).isActive = true
        controller.view.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        controller.fireButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        controller.addTabButton.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        controller.tabSwitcherButton.delegate = self
    }
    
    private func configureOmniBar() {
        if AppWidthObserver.shared.isLargeWidth {
            viewCoordinator.omniBar.enterPadState()
        }
        viewCoordinator.omniBar.omniDelegate = self
    }
    
    @objc func buttonPressed(sender: Any) {
        userInteractionDetected()
    }
    
    @IBAction func userInteractionDetected() {
        Pixel.fire(pixel: .blankOverlayNotDismissed)
        delegate?.recoverFromPresenting(controller: self)
    }
}

extension BlankSnapshotViewController: OmniBarDelegate {
    func onVoiceSearchPressed() {
       // No-op
    }
    
    func selectedSuggestion() -> Suggestion? {
        return nil
    }

    func onOmniSuggestionSelected(_ suggestion: Suggestion) {
        // No-op
    }

    func onSettingsPressed() {
        userInteractionDetected()
    }
    
    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) -> Bool {
        DispatchQueue.main.async {
            self.viewCoordinator.omniBar.resignFirstResponder()
            self.userInteractionDetected()
        }
        return false
    }
    
    func onEnterPressed() {
        userInteractionDetected()
    }
}

extension BlankSnapshotViewController: TabSwitcherButtonDelegate {
    
    func showTabSwitcher(_ button: TabSwitcherButton) {
        userInteractionDetected()
    }
    
    func launchNewTab(_ button: TabSwitcherButton) {
        userInteractionDetected()
    }
    
}

extension BlankSnapshotViewController: Themable {
    
    func decorate(with theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()

        if AppWidthObserver.shared.isLargeWidth {
            viewCoordinator.statusBackground.backgroundColor = theme.tabsBarBackgroundColor
        } else {
            viewCoordinator.statusBackground.backgroundColor = theme.omniBarBackgroundColor
        }

        view.backgroundColor = theme.mainViewBackgroundColor

        viewCoordinator.navigationBarContainer.backgroundColor = theme.barBackgroundColor
        viewCoordinator.navigationBarContainer.tintColor = theme.barTintColor

        viewCoordinator.omniBar.decorate(with: theme)

        viewCoordinator.progress.decorate(with: theme)

        viewCoordinator.toolbar.barTintColor = theme.barBackgroundColor
        viewCoordinator.toolbar.tintColor = theme.barTintColor

        tabSwitcherButton.decorate(with: theme)
        viewCoordinator.toolbarTabSwitcherButton.tintColor = theme.barTintColor

        viewCoordinator.logoText.tintColor = theme.ddgTextTintColor

        if appSettings.currentAddressBarPosition == .bottom {
            viewCoordinator.statusBackground.backgroundColor = theme.backgroundColor
        }

        menuButton.decorate(with: theme)

     }
    
}
