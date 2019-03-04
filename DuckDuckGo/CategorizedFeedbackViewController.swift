//
//  CategorizedFeedbackViewController.swift
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

class CategorizedFeedbackViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    private var options = [String]()
    private var selectionHandler: (String) -> Void = { _ in }
    
    private(set) var selectedCategory: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let headerView = tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
    
    func configure(with categories: [DisambiguatedFeedbackCategory]) {
        options = categories.map { $0.rawValue }
    }
    
    func configureForSubcategories(with category: DisambiguatedFeedbackCategory) {
        supplementaryText.text = category.subcategoryCaption
        options = category.subcategories
    }
    
    func setSelectionHandler(_ handler: @escaping (String) -> Void) {
        self.selectionHandler = handler
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedCategory = options[indexPath.row]
        selectionHandler(options[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") else {
            fatalError("Failed to dequeue CategoryCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.contentView.backgroundColor = theme.tableCellBackgroundColor
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.textLabel?.textColor = theme.tableCellTintColor
        cell.textLabel?.text = options[indexPath.row]
        
        return cell
    }

}

extension CategorizedFeedbackViewController {
    
    func presentSubmitFeedbackScreen(a: String, b: String) {
        performSegue(withIdentifier: "PresentSubmitFeedback", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let controller = segue.destination as? SubmitFeedbackViewController else {
            return
        }
        
        controller.loadViewIfNeeded()
        controller.configureForNegativeSentiment(headerText: "aaa", detailsText: "bbb")
    }
}

extension CategorizedFeedbackViewController: Themable {
    
    func decorate(with theme: Theme) {
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        headerView.backgroundColor = theme.backgroundColor
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
    }
    
}
