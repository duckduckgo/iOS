//
//  SafariSearchInstructionsViewController.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
import SwiftRichString

class SafariSearchInstructionsViewController: UIViewController {
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var instructionsSettingsText: UILabel!
    @IBOutlet weak var instructionsNavigateText: UILabel!
    @IBOutlet weak var instructionsSelectText: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var descriptionLineHeight: CGFloat = 0

    private static let minimumTopMargin: CGFloat = 14
    private static let verticalOffset: CGFloat = 20

    private lazy var tutorialSettings = TutorialSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !tutorialSettings.hasSeenSafariSearchInstructions {
            disableDoneButtonForASecond()
            tutorialSettings.hasSeenSafariSearchInstructions = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        applyTopMargin()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        applyTopMargin()
        configureViews()
    }

    @IBAction func onDonePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    private func disableDoneButtonForASecond() {
        doneButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.doneButton.isEnabled = true
        }
    }

    private func configureViews() {
        descriptionText.adjustPlainTextLineHeight(descriptionLineHeight)

        let style = makeStyle()
        instructionsSettingsText.attributedText = UserText.safariInstructionsSettings.parse()?.render(withStyles: [style])
        instructionsNavigateText.attributedText = UserText.safariInstructionsNavigate.parse()?.render(withStyles: [style])
        instructionsSelectText.attributedText = UserText.safariInstructionsSelect.parse()?.render(withStyles: [style])
    }
    
    private func applyTopMargin() {
        let availableHeight = view.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let excessHeight = availableHeight - contentHeight
        let marginForVerticalCentering = (excessHeight  / 2) - SafariSearchInstructionsViewController.verticalOffset
        let minimumMargin = SafariSearchInstructionsViewController.minimumTopMargin
        topMarginConstraint.constant = marginForVerticalCentering > minimumMargin ? marginForVerticalCentering : minimumMargin
    }

    private func makeStyle() -> Style {
        return Style("highlight", {
            $0.color = UIColor(hex: "#333333", alpha: 1.0)
        })
    }

}

