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

class SafariSearchInstructionsViewController: UIViewController {
    
    @IBOutlet weak var topMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var descriptionText: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    var descriptionLineHeight: CGFloat = 0

    private static let minimumTopMargin: CGFloat = 14
    private static let verticalOffset: CGFloat = 20

    private lazy var tutorialSettings = TutorialSettings()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }
 
    private func configureViews() {
        descriptionText.adjustPlainTextLineHeight(descriptionLineHeight)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !tutorialSettings.hasSeenSafariSearchInstructions {
            disableDoneButtonForASecond()
            tutorialSettings.hasSeenSafariSearchInstructions = true
        }
    }
    
    private func disableDoneButtonForASecond() {
        doneButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.doneButton.isEnabled = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        applyTopMargin()
    }
    
    private func applyTopMargin() {
        let availableHeight = view.frame.size.height
        let contentHeight = scrollView.contentSize.height
        let excessHeight = availableHeight - contentHeight
        let marginForVerticalCentering = (excessHeight  / 2) - SafariSearchInstructionsViewController.verticalOffset
        let minimumMargin = SafariSearchInstructionsViewController.minimumTopMargin
        topMarginConstraint.constant = marginForVerticalCentering > minimumMargin ? marginForVerticalCentering : minimumMargin
    }
    
    @IBAction func onDonePressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
