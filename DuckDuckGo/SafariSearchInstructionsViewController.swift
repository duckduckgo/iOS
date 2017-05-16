//
//  SafariSearchInstructionsViewController.swift
//  DuckDuckGo
//
//  Created by Mia Alexiou on 01/03/2017.
//  Copyright © 2017 DuckDuckGo. All rights reserved.
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
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
