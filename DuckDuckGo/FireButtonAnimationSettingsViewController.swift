//
//  FireButtonAnimationSettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2020 DuckDuckGo. All rights reserved.
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

class FireButtonAnimationSettingsViewController: UITableViewController {
         
    private lazy var appSettings = AppDependencyProvider.shared.appSettings
    
    private lazy var availableAnimations = FireButtonAnimationType.allCases

    private var animator: FireButtonAnimator = FireButtonAnimator(appSettings: AppUserDefaults())

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableAnimations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FireAnimationTypeCell", for: indexPath)
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? FireAnimationTypeCell else {
            fatalError("Expected FireAnimationTypeCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor
        cell.nameLabel.textColor = theme.tableCellTextColor
        
        let animationType = availableAnimations[indexPath.row]
        cell.name = animationType.descriptionText

        cell.accessoryType = animationType == appSettings.currentFireButtonAnimation ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let type = availableAnimations[indexPath.row]
        appSettings.currentFireButtonAnimation = type
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.currentFireButtonAnimationChange, object: self)
        tableView.reloadData()

        animator.animate {
            // no op
        } onTransitionCompleted: {
            // no op
        } completion: {
            // no op
        }

    }
}

class FireAnimationTypeCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!

    var name: String? {
        get {
            return nameLabel.text
        }
        set {
            nameLabel.text = newValue
        }
    }
}

extension FireButtonAnimationSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
