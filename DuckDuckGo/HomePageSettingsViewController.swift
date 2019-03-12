//
//  HomePageSettingsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/03/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit
import Core

protocol HomePageSettingsDelegate: NSObjectProtocol {
    
    func homePageChanged(toConfigName config: HomePageConfiguration.ConfigName)
    
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
        
        // Checkmark color
        cell.tintColor = theme.toggleSwitchColor
        
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
        delegate?.homePageChanged(toConfigName: config)
        tableView.reloadData()
    }
    
}

extension HomePageSettingsViewController: Themable {

    func decorate(with theme: Theme) {
        
        for label in labels {
            label.textColor = theme.tableCellTintColor
        }
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
    }
}
