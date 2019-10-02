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
    
    func homePageChanged(to config: HomePageConfiguration.ConfigName)
    
}

class HomePageSettingsViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!

    weak var delegate: HomePageSettingsDelegate?
    
    private lazy var appSettings = AppDependencyProvider.shared.appSettings

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.setHighlightedStateBackgroundColor(theme.tableCellHighlightedBackgroundColor)
        
        // Checkmark color
        cell.tintColor = theme.buttonTintColor
        
        cell.accessoryType = indexPath.row == appSettings.homePage.rawValue ? .checkmark : .none
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard appSettings.homePage.rawValue != indexPath.row else { return }
        let config = HomePageConfiguration.ConfigName(rawValue: indexPath.row)!
        
        switch config {
        case .simple:
            Pixel.fire(pixel: .settingsHomePageSimple)

        case .centerSearch:
            Pixel.fire(pixel: .settingsHomePageCenterSearch)
            
        case .centerSearchAndFavorites:
            Pixel.fire(pixel: .settingsHomePageCenterSearchAndFavorites)
        }
        
        appSettings.homePage = config
        delegate?.homePageChanged(to: config)
        tableView.reloadData()
    }
    
}

extension HomePageSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTextColor
        }
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
