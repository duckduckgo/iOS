//
//  AccessibilitySettingsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2021 DuckDuckGo. All rights reserved.
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

import Foundation
import UIKit

class AccessibilitySettingsViewController: UITableViewController {
    
    @IBOutlet weak var textSizeSlider: UISlider!
    @IBOutlet weak var currentSelectedValueLabel: UILabel!
    
    private let predefinedPercentages = [50, 75, 85, 100, 115, 125, 150, 175, 200]
    private var currentSelectedValue = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSlider()
        updateLabel()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 15.0, *) {
            if let sheetController = navigationController?.presentationController as? UISheetPresentationController {
                sheetController.detents = [.medium(), .large()]
                sheetController.animateChanges {
                  sheetController.selectedDetentIdentifier = .medium
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if #available(iOS 15.0, *) {
            if let sheetController = navigationController?.presentationController as? UISheetPresentationController {
                sheetController.detents = [.large()]
                sheetController.animateChanges {
                  sheetController.selectedDetentIdentifier = .large
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    private func configureSlider() {
        textSizeSlider.minimumValue = 0
        textSizeSlider.maximumValue = Float(predefinedPercentages.count - 1)
        
        let currentSelectionIndex = predefinedPercentages.firstIndex(of: currentSelectedValue) ?? 0
        textSizeSlider.value = Float(currentSelectionIndex)
    }
    
    private func updateLabel() {
        currentSelectedValueLabel.text = "Text Size - \(currentSelectedValue)%"
    }
}

extension AccessibilitySettingsViewController {
    
    @IBAction func onNewTabValueChanged(_ sender: Any) {
        let roundedValue = round(textSizeSlider.value)
        let index = Int(roundedValue)

        print("slider: \(textSizeSlider.value) rounded:\(roundedValue) - [\(index) = \(predefinedPercentages[index])]")

        // snap the slider
        textSizeSlider.value = roundedValue
        
        let newValue = predefinedPercentages[index]
        if newValue != currentSelectedValue {
            currentSelectedValue = newValue
            // update UI
            updateLabel()
        }
    }
}

extension AccessibilitySettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
