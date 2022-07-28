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
import SwiftUI
import Core

struct TextSizeSettingsView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> TextSizeSettingsViewController {
        UIStoryboard(name: "Settings", bundle: nil)
            .instantiateViewController(identifier: "TextSizeSettingsViewController",
                                       creator: TextSizeSettingsViewController.init(coder:))
    }

    func updateUIViewController(_ uiViewController: TextSizeSettingsViewController, context: Context) {
    }

}
class TextSizeSettingsViewController: UITableViewController {
    
    @IBOutlet var customBackBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var customBackInnerButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var textSizeSlider: IntervalSlider!
    @IBOutlet weak var smallerTextIcon: UIImageView!
    @IBOutlet weak var largerTextIcon: UIImageView!
    @IBOutlet weak var currentSelectedValueLabel: UILabel!
    
    private let predefinedPercentages = [80, 90, 100, 110, 120, 130, 140, 150, 160, 170]
    
    private let initialTextSizePercentage: Int = AppDependencyProvider.shared.appSettings.textSize
    private var currentTextSizePercentage: Int = AppDependencyProvider.shared.appSettings.textSize
    
    private var hasAdjustedDetent: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = nil
        
        configureCustomBackButtonTitle()
        configureDescriptionLabel()
        configureSlider()
        updateTextSizeFooterLabel()
        
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
                
                navigationItem.leftBarButtonItem = customBackBarButtonItem
                
                hasAdjustedDetent = true
            }
        }
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    
        if parent == nil {
            firePixelForTextSizeChange()
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    private func configureCustomBackButtonTitle() {
        let topViewController = navigationController?.topViewController
        let previousViewController = navigationController?.viewControllers.last(where: { $0 != topViewController })
        let backTitle = previousViewController?.navigationItem.title ?? ""

        customBackInnerButton.setTitle(backTitle, for: .normal)
    }
    
    private func configureDescriptionLabel() {
        descriptionLabel.text = UserText.textSizeDescription
        adjustDescriptionLabelHeight()
    }
    
    private func adjustDescriptionLabelHeight() {
        guard let headerView = tableView.tableHeaderView else { return }
            
        let adjustedSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if headerView.frame.size.height != adjustedSize.height {
            headerView.frame.size.height = adjustedSize.height
        }
    }
    
    private func configureSlider() {
        textSizeSlider.minimumValue = 0
        textSizeSlider.maximumValue = Float(predefinedPercentages.count - 1)
        
        textSizeSlider.steps = predefinedPercentages.count
        
        configureSliderCurrentSelection()
    }
    
    private func configureSliderCurrentSelection() {
        let currentSelectionIndex = predefinedPercentages.firstIndex(of: currentTextSizePercentage) ?? 0
        textSizeSlider.value = Float(currentSelectionIndex)
    }
    
    private func updateTextSizeFooterLabel() {
        let percentageString = "\(currentTextSizePercentage)%"
        currentSelectedValueLabel.text = UserText.textSizeFooter(for: percentageString)
        
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
                        self.navigationItem.leftBarButtonItem = nil
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        if shouldPopViewController {
            navigationItem.leftBarButtonItem = nil
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func onSliderValueChanged(_ sender: Any) {
        let roundedValue = round(textSizeSlider.value)
    
        // make the slider snap
        textSizeSlider.value = roundedValue
    
        let index = Int(roundedValue)
        let newTextSizePercentage = predefinedPercentages[index]
        
        if newTextSizePercentage != currentTextSizePercentage {
            currentTextSizePercentage = newTextSizePercentage

            updateTextSizeFooterLabel()
            storeTextSizeInAppSettings(currentTextSizePercentage)
        }
    }
    
    private func storeTextSizeInAppSettings(_ percentage: Int) {
        let appSettings = AppDependencyProvider.shared.appSettings
        appSettings.textSize = percentage
        
        NotificationCenter.default.post(name: AppUserDefaults.Notifications.textSizeChange, object: self)
    }
    
    private func firePixelForTextSizeChange() {
        guard initialTextSizePercentage != currentTextSizePercentage else { return }
        
        Pixel.fire(pixel: .textSizeSettingsChanged, withAdditionalParameters: [PixelParameters.textSizeInitial: "\(initialTextSizePercentage)",
                                                                               PixelParameters.textSizeUpdated: "\(currentTextSizePercentage)"])
    }
}

@available(iOS 15.0, *)
extension TextSizeSettingsViewController: UISheetPresentationControllerDelegate {
    
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        navigationItem.leftBarButtonItem = sheetPresentationController.selectedDetentIdentifier == .medium ? customBackBarButtonItem : nil
    }
}

extension TextSizeSettingsViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        firePixelForTextSizeChange()
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
