//
//  HomePageSettingsDelegate.swift
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

protocol HomePageSettingsDelegate: NSObjectProtocol {
    
    func homePageChanged()
    
}

class HomePageSettingsViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var favoritesToggle: UISwitch!

    weak var delegate: HomePageSettingsDelegate?

    var settings = DefaultHomePageSettings()

    override func viewDidLoad() {
        super.viewDidLoad()

        favoritesToggle.isOn = settings.favorites
        applyTheme(ThemeManager.shared.currentTheme)
    }

    @IBAction func toggleFavorites() {
        settings.favorites = favoritesToggle.isOn
        delegate?.homePageChanged()
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
        
        guard indexPath.section == 0 else { return }

        let layoutSetting = indexPath.row == 0 ? HomePageLayout.navigationBar : .centered
        cell.accessoryType = settings.layout == layoutSetting ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }

        tableView.deselectRow(at: indexPath, animated: true)

        settings.layout = indexPath.row == 0 ? .navigationBar : .centered

        delegate?.homePageChanged()

        tableView.reloadData()
    }
    
}

extension HomePageSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }

        favoritesToggle.onTintColor = theme.buttonTintColor

        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
