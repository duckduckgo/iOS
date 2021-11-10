//
//  TextSizeSettingsViewController.swift
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

class TextSizeSettingsViewController: UITableViewController {
    
    @IBOutlet var customBackBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var customBackInnerButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textSizeSlider: IntervalSlider!
    @IBOutlet weak var smallerTextIcon: UIImageView!
    @IBOutlet weak var largerTextIcon: UIImageView!
    @IBOutlet weak var currentSelectedValueLabel: UILabel!
    
    private let predefinedPercentages = [80, 90, 100, 110, 120, 130, 140, 150, 160, 170]
    
    private var currentSelectedValue: Int = Int(AppDependencyProvider.shared.appSettings.textSizeAdjustment * 100)
    
    private var hasAdjustedDetent: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("leftBarButtonItem: nil")
        navigationItem.leftBarButtonItem = nil
        
        configureCustomBackButtonTitle()
        configureSlider()
        updateLabel()
        applyTheme(ThemeManager.shared.currentTheme)
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        adjustDetentOnPresentation()
    }
    
    private func adjustDetentOnPresentation() {
        if #available(iOS 15.0, *) {
            if !hasAdjustedDetent, let sheetController = navigationController?.presentationController as? UISheetPresentationController {
                sheetController.detents = [.medium(), .large()]
                sheetController.delegate = self
                
                sheetController.animateChanges {
                    sheetController.selectedDetentIdentifier = .medium
                }
                
                print("leftBarButtonItem: custom")
                navigationItem.leftBarButtonItem = customBackBarButtonItem
                
                hasAdjustedDetent = true
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    @IBAction func customBackButtonTapped(_ sender: AnyObject) {
        var shouldPopViewController: Bool = true
        
        if #available(iOS 15.0, *) {
            if let sheetController = navigationController?.presentationController as? UISheetPresentationController {
                sheetController.detents = [.large()]
                
                // We recreate two-step detent animation, like on push but in reverse
                if sheetController.selectedDetentIdentifier != .large {
                    shouldPopViewController = false
                    
                    // First step is to animate detent to large
                    sheetController.animateChanges {
                        sheetController.selectedDetentIdentifier = .large
                    }
                    
                    // Second step is to actually pop the view controller
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        print("leftBarButtonItem: nil")
                        self.navigationItem.leftBarButtonItem = nil
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        if shouldPopViewController {
            print("leftBarButtonItem: nil")
            navigationItem.leftBarButtonItem = nil
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureCustomBackButtonTitle() {
        let topViewController = navigationController?.topViewController
        let previousViewController = navigationController?.viewControllers.last(where: { $0 != topViewController })
        let backTitle = previousViewController?.navigationItem.title ?? ""

        customBackInnerButton.setTitle(backTitle, for: .normal)
    }
    
    private func configureSlider() {
        textSizeSlider.minimumValue = 0
        textSizeSlider.maximumValue = Float(predefinedPercentages.count - 1)
        textSizeSlider.steps = predefinedPercentages.count - 1
        
        let currentSelectionIndex = predefinedPercentages.firstIndex(of: currentSelectedValue) ?? 0
        textSizeSlider.value = Float(currentSelectionIndex)
    }
    
    private func updateLabel() {
        let percentageString = "\(currentSelectedValue)%"
        currentSelectedValueLabel.text = UserText.textSizeFooter(for: percentageString)
        
    }
}

extension TextSizeSettingsViewController {
    
    @IBAction func onSliderValueChanged(_ sender: Any) {
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
            
            let appSettings = AppDependencyProvider.shared.appSettings
            appSettings.textSizeAdjustment = Float(newValue)/100
            
            Swift.print("appSettings: \(appSettings.textSizeAdjustment) based on  \(newValue)%")
            
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.textSizeAdjustmentChange, object: self)
        }
    }
}

extension TextSizeSettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        descriptionLabel.textColor = theme.tableCellTextColor
        smallerTextIcon.tintColor = theme.tableCellTextColor
        largerTextIcon.tintColor = theme.tableCellTextColor
        currentSelectedValueLabel.textColor = theme.tableHeaderTextColor
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}

extension TextSizeSettingsViewController: UISheetPresentationControllerDelegate {
  @available(iOS 15.0, *)
  func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {

      if sheetPresentationController.selectedDetentIdentifier == .large {
          print("leftBarButtonItem: nil")
          navigationItem.leftBarButtonItem = nil
      } else if sheetPresentationController.selectedDetentIdentifier == .medium {
          print("leftBarButtonItem: custom")
          navigationItem.leftBarButtonItem = customBackBarButtonItem
      }
  }
}
