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
    private var selectionHandler: (DisambiguatedFeedbackModel) -> Void = { _ in }
    
    private var existingModel: DisambiguatedFeedbackModel?

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
    
    func configureForSubcategories(with model: DisambiguatedFeedbackModel) {
        guard let category = model.category else {
            fatalError("Feedback model has empty category")
        }
        
        existingModel = model
        
        let headerString = headerText.attributedText?.mutableCopy() as? NSMutableAttributedString
        headerString?.mutableString.setString(category.caption)
        headerText.attributedText = headerString
        
        let supplementaryString = supplementaryText.attributedText?.mutableCopy() as? NSMutableAttributedString
        supplementaryString?.mutableString.setString(category.subcategoriesCaption)
        supplementaryText.attributedText = supplementaryString
        
        options = category.subcategories
    }
    
    func setSelectionHandler(_ handler: @escaping (DisambiguatedFeedbackModel) -> Void) {
        self.selectionHandler = handler
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var model: DisambiguatedFeedbackModel
        if let existingModel = existingModel {
            model = existingModel
        } else {
            model = DisambiguatedFeedbackModel()
        }
        
        if model.category == nil {
            model.category = DisambiguatedFeedbackCategory(rawValue: options[indexPath.row])
        } else {
            model.subcategory = options[indexPath.row]
        }
        
        selectionHandler(model)
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
        
        let text = cell.textLabel?.attributedText?.mutableCopy() as? NSMutableAttributedString
        text?.mutableString.setString(options[indexPath.row])
        cell.textLabel?.attributedText = text
        
        return cell
    }

}

extension CategorizedFeedbackViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? SubmitFeedbackViewController,
            let model = sender as? DisambiguatedFeedbackModel {
            controller.loadViewIfNeeded()
            
            let detailsText: String
            if let subcategory = model.subcategory,
                subcategory != DisambiguatedFeedbackCategory.otherIssues.rawValue {
                detailsText = subcategory
            } else {
                detailsText = "Please tell us what we can improve"
            }
            
            controller.configureForNegativeSentiment(headerText: model.category?.caption ?? "",
                                                     detailsText: detailsText)
            return
        }
        
        if let controller = segue.destination as? SiteFeedbackViewController {
            controller.prepareForSegue(isBrokenSite: true, url: nil)
            return
        }
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
