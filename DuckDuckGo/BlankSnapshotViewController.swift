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

class BlankSnapshotViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ThemeManager.shared.currentTheme.statusBarStyle
    }
    
    @IBOutlet weak var customNavigationBar: UIView!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var statusBarBackground: UIView!
    
    var omniBar: OmniBar!
    let tabSwitcherButton = TabSwitcherButton()
    
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
        tabsButton.customView = tabSwitcherButton
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    private func configureOmniBar(homePageSettings: HomePageSettings = DefaultHomePageSettings()) {
        if homePageSettings.layout == .navigationBar {
            omniBar = OmniBar.loadFromXib()
            omniBar.frame = customNavigationBar.bounds
            customNavigationBar.addSubview(omniBar)
        } else {
            statusBarBackground.isHidden = true
            customNavigationBar.isHidden = true
        }
    }
}

extension BlankSnapshotViewController: Themable {
    
    func decorate(with theme: Theme) {
        setNeedsStatusBarAppearanceUpdate()
        
        view.backgroundColor = theme.backgroundColor
        
        statusBarBackground.backgroundColor = theme.barBackgroundColor
        customNavigationBar?.backgroundColor = theme.barBackgroundColor
        customNavigationBar?.tintColor = theme.barTintColor
        
        omniBar?.decorate(with: theme)
        
        toolbar?.barTintColor = theme.barBackgroundColor
        toolbar?.tintColor = theme.barTintColor
        
        tabSwitcherButton.decorate(with: theme)
        tabsButton.tintColor = theme.barTintColor
    }
    
}
