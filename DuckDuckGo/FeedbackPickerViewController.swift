//
//  FeedbackPickerViewController.swift
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

class FeedbackPickerViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerText: UILabel!
    @IBOutlet weak var supplementaryText: UILabel!
    
    private var entries = [FeedbackEntry]()
    private var selectionHandler: (Feedback.Model) -> Void = { _ in }
    
    private var feedbackModel: Feedback.Model?
    
    static func loadFromStoryboard() -> FeedbackPickerViewController {
        let storyboard = UIStoryboard(name: "Feedback", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "FeedbackPicker") as? FeedbackPickerViewController else {
            fatalError("Failed to load view controller for Feedback Picker")
        }
        return controller
    }

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
    
    func configure(with categories: [Feedback.Category]) {
        entries = categories
        
        headerText.setAttributedTextString(UserText.feedbackNegativeHeader)
        supplementaryText.setAttributedTextString(UserText.feedbackNegativeSupplementary)
    }
    
    func configureFor(entries: [FeedbackEntry], with model: Feedback.Model) {
        guard let category = model.category else {
            fatalError("Feedback model has empty category")
        }
        
        loadViewIfNeeded()
        feedbackModel = model
        
        headerText.setAttributedTextString(FeedbackPresenter.title(for: category))
        supplementaryText.setAttributedTextString(FeedbackPresenter.subtitle(for: category))
        
        self.entries = entries
    }
    
    func setSelectionHandler(_ handler: @escaping (Feedback.Model) -> Void) {
        self.selectionHandler = handler
    }
    
    @IBAction func dismissButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedEntry = entries[indexPath.row]

        var model = feedbackModel ?? Feedback.Model()
        if model.category == nil {
            model.category = selectedEntry as? Feedback.Category
        } else {
            model.subcategory = selectedEntry
        }
        
        FeedbackNavigator.navigate(to: selectedEntry.nextStep, from: self, with: model)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") else {
            fatalError("Failed to dequeue CategoryCell")
        }
        
        let theme = ThemeManager.shared.currentTheme
        cell.backgroundColor = theme.tableCellBackgroundColor
        cell.textLabel?.textColor = theme.tableCellTextColor
        
        let text = cell.textLabel?.attributedText?.mutableCopy() as? NSMutableAttributedString
        text?.mutableString.setString(entries[indexPath.row].userText)
        cell.textLabel?.attributedText = text
        
        return cell
    }
}

extension FeedbackPickerViewController: Themable {
    
    func decorate(with theme: Theme) {
        tableView.separatorColor = theme.tableCellSeparatorColor
        tableView.backgroundColor = theme.backgroundColor
        
        headerView.backgroundColor = theme.backgroundColor
        headerText.textColor = theme.feedbackPrimaryTextColor
        supplementaryText.textColor = theme.feedbackSecondaryTextColor
        
        tableView.reloadData()
    }
    
}
