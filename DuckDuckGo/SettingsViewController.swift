//
//  SettingsViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 30/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var newTabeModeToggle: UISwitch!
    @IBOutlet weak var versionText: UILabel!
    
    private lazy var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNewTabModeToggle()
        configureVersionText()
    }

    private func configureNewTabModeToggle() {
        newTabeModeToggle.isOn = settings.launchNewTabInActiveMode
    }
    
    private func configureVersionText() {
        let version = Version()
        versionText.text = version.localized()
    }

    
    @IBAction func onNewTabModeToggled(_ sender: UISwitch) {
        settings.launchNewTabInActiveMode = newTabeModeToggle.isOn
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
