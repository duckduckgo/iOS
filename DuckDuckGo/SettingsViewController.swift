//
//  SettingsViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 30/01/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var versionText: UILabel!
    
    private lazy var settings = Settings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVersionText()
    }
    
    private func configureVersionText() {
        let version = Version()
        versionText.text = version.localized()
    }
    
    @IBAction func onDonePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 1 {
            launchOnboardingFlow()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func launchOnboardingFlow() {
        let controller = OnboardingViewController.loadFromStoryboard(doneButtonStyle: .close)
        controller.modalTransitionStyle = .flipHorizontal
        present(controller, animated: true, completion: nil)
    }
}
