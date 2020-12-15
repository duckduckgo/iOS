//
//  ReportBrokenSiteViewController.swift
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

class ReportBrokenSiteViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var headerLabel: UILabel!
    
    @IBOutlet var submitButton: UIBarButtonItem!
    
    public var brokenSiteInfo: BrokenSiteInfo?
    
    private var selectedCategory: Int? {
        didSet {
            submitButton.isEnabled = true
        }
    }
    
    private let categories: [BrokenSite.Category] = {
        var categories = BrokenSite.Category.allCases
        categories = categories.filter { $0 != .other }
        categories = categories.shuffled()
        categories.append(.other)
        return categories
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.isEnabled = false
        headerLabel.setAttributedTextString(UserText.reportBrokenSiteHeader)
        applyTheme(ThemeManager.shared.currentTheme)
        
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onClosePressed(sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onSubmitPressed(sender: Any) {
        guard let selectedCategory = selectedCategory else {
            fatalError("Category should be selected!")
        }
        
        brokenSiteInfo?.send(with: categories[selectedCategory].rawValue)
        view.window?.makeToast(UserText.feedbackSumbittedConfirmation)
        dismiss(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let header = tableView.tableHeaderView {
            let newSize = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            header.frame.size.height = newSize.height
            DispatchQueue.main.async {
                self.tableView.tableHeaderView = header
            }
        }
    }
}

extension ReportBrokenSiteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrokenSiteCategoryCell") else {
            fatalError("Failed to dequeue cell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.textLabel?.textColor = theme.tableCellTextColor
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.tintColor = theme.buttonTintColor
        
        if let selectedIndex = selectedCategory, selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        cell.textLabel?.text = categories[indexPath.row].categoryText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UserText.brokenSiteSectionTitle
    }
}

extension ReportBrokenSiteViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = indexPath.row
        tableView.reloadData()
    }
}

extension ReportBrokenSiteViewController: Themable {
    
    func decorate(with theme: Theme) {
        decorateNavigationBar(with: theme)
        
        view.backgroundColor = theme.backgroundColor
        headerView.backgroundColor = theme.backgroundColor
        headerLabel.textColor = theme.homeRowSecondaryTextColor
        
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        tableView.reloadData()
    }
}
