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
    
    @IBOutlet weak var textSizeSlider: IntervalSlider!
    @IBOutlet weak var currentSelectedValueLabel: UILabel!
    
    private let predefinedPercentages = [80, 90, 100, 110, 120, 130, 140, 150, 160, 170]
    
    private var currentSelectedValue: Int = Int(AppDependencyProvider.shared.appSettings.textSizeAdjustment * 100)
    
    private var hasAdjustedDetent: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSlider()
        updateLabel()
        applyTheme(ThemeManager.shared.currentTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 15.0, *) {
            if !hasAdjustedDetent, let sheetController = navigationController?.presentationController as? UISheetPresentationController {
                sheetController.detents = [.medium(), .large()]
                sheetController.animateChanges {
                    sheetController.selectedDetentIdentifier = .medium
                    hasAdjustedDetent = true
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let theme = ThemeManager.shared.currentTheme
        cell.decorate(with: theme)
    }
    
    @IBAction func backButtonTapped(_ sender: AnyObject) {
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
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        
        if shouldPopViewController {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func configureSlider() {
        textSizeSlider.minimumValue = 0
        textSizeSlider.maximumValue = Float(predefinedPercentages.count - 1)
        textSizeSlider.steps = predefinedPercentages.count - 1
        
        let currentSelectionIndex = predefinedPercentages.firstIndex(of: currentSelectedValue) ?? 0
        textSizeSlider.value = Float(currentSelectionIndex)
    }
    
    private func updateLabel() {
        currentSelectedValueLabel.text = "Text Size - \(currentSelectedValue)%"
    }
}

class IntervalSlider: UISlider {
    
    var steps: Int = 1 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let trackRect = trackRect(forBounds: rect)
        let thumbRect = thumbRect(forBounds: rect, trackRect: trackRect, value: 1.0)
        
        print("track: \(trackRect)")
        print("thumb: \(thumbRect)")
        
        let thumbWidth = thumbRect.width
        print("thumbWidth: \(thumbWidth)")
        
//        let thumbOffset = thumbRect.width/2 - 2
        let thumbOffset = Darwin.round(thumbRect.width/2) - 3
        print("thumbOffset: \(thumbOffset)")
        
        let newTrackRect = trackRect.inset(by: UIEdgeInsets(top: 0.0, left: thumbOffset, bottom: 0.0, right: thumbOffset))
                
        print("  new: \(newTrackRect)")
        
        let color: UIColor = UIColor.cornflowerBlue
        let bpath: UIBezierPath = UIBezierPath(rect: newTrackRect)

        color.set()
        bpath.fill()
        
        for i in 0...steps {
//            let trackWidth = newTrackRect.width
//            let height = rect.height
            let markWidth = 3.0
            let markHeight = 9.0
            
//            let x = Darwin.round(newTrackRect.minX + newTrackRect.width/CGFloat(count) * CGFloat(i) - markWidth/2)
            let x = newTrackRect.minX + newTrackRect.width/CGFloat(steps) * CGFloat(i) - markWidth/2
            let xRounded = Darwin.round(x / 0.5) * 0.5
            
            let markRect = CGRect(x: xRounded, y: newTrackRect.midY - markHeight/2, width: markWidth, height: markHeight)
            print("mark[\(i)]: \(markRect)")
            
            let markPath: UIBezierPath = UIBezierPath(roundedRect: markRect, cornerRadius: 5.0)
            color.set()
        
            markPath.fill()
        }
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
            
            let appSettings = AppDependencyProvider.shared.appSettings
            appSettings.textSizeAdjustment = Float(newValue)/100
            
            Swift.print("appSettings: \(appSettings.textSizeAdjustment) based on  \(newValue)%")
            
            NotificationCenter.default.post(name: AppUserDefaults.Notifications.textSizeAdjustmentChange, object: self)
        }
    }
}

extension AccessibilitySettingsViewController: Themable {
    
    func decorate(with theme: Theme) {
        
        // TODO: Tweak style of othre elements too
        
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.tableCellSeparatorColor
        
        tableView.reloadData()
    }
}
