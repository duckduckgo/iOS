//
//  HomePageSettingsViewController.swift
//  DuckDuckGo
//
//  Created by Chris Brind on 11/03/2019.
//  Copyright © 2019 DuckDuckGo. All rights reserved.
//

import UIKit

class HomePageSettingsViewController: UITableViewController {
    
    @IBOutlet var labels: [UILabel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
 
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        
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
