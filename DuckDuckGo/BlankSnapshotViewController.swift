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

class BlankSnapshotViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    let menuButton = MenuButton()
    @IBOutlet weak var lastButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var statusBarBackground: UIView!
    @IBOutlet weak var navigationBarTop: NSLayoutConstraint!
    
    var omniBar: OmniBar!
    let tabSwitcherButton = TabSwitcherButton()
    
    weak var delegate: BlankSnapshotViewRecoveringDelegate?
    
    static func loadFromStoryboard() -> BlankSnapshotViewController {
        let storyboard = UIStoryboard(name: "BlankSnapshot", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? BlankSnapshotViewController else {
            fatalError("Failed to instantiate correct Blank Snapshot view controller")
        }
        return controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureOmniBar()

        if AppWidthObserver.shared.isLargeWidth {
            toolbar.isHidden = true
            navigationBarTop.constant = 40
            configureTabBar()
        } else {
            tabsButton.customView = tabSwitcherButton
            tabSwitcherButton.delegate = self
            
            menuButton.setState(.menuImage, animated: false)
            lastButton.customView = menuButton
        }

        applyTheme(ThemeManager.shared.currentTheme)
    }

    // Need to do this at this phase to support split screen on iPad
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        toolbar.isHidden = AppWidthObserver.shared.isLargeWidth
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
        omniBar = OmniBar.loadFromXib()
        omniBar.frame = customNavigationBar.bounds
        customNavigationBar.addSubview(omniBar)

        if AppWidthObserver.shared.isLargeWidth {
            omniBar.enterPadState()
        }
        
        omniBar.omniDelegate = self
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
    
    func onSettingsPressed() {
        userInteractionDetected()
    }
    
    func onTextFieldDidBeginEditing(_ omniBar: OmniBar) -> Bool {
        DispatchQueue.main.async {
            self.omniBar.resignFirstResponder()
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
        
        view.backgroundColor = theme.backgroundColor
        
        if AppWidthObserver.shared.isLargeWidth {
            statusBarBackground.backgroundColor = theme.tabsBarBackgroundColor
        } else {
            statusBarBackground.backgroundColor = theme.barBackgroundColor
        }
        customNavigationBar?.backgroundColor = theme.barBackgroundColor
        customNavigationBar?.tintColor = theme.barTintColor
        
        omniBar?.decorate(with: theme)
        
        toolbar?.barTintColor = theme.barBackgroundColor
        toolbar?.tintColor = theme.barTintColor
        
        tabSwitcherButton.decorate(with: theme)
        tabsButton.tintColor = theme.barTintColor
        
        menuButton.decorate(with: theme)
    }
    
}
